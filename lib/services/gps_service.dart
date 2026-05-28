// gps_service.dart — ThrottleIQ telemetry core with smoothing & behavior analysis.
//
// Upgrades in this version:
//   • EMA speed smoothing (α=0.30) — eliminates GPS jitter
//   • Heading tracking for turn detection
//   • TelemetryAnalyzer integration — live accel/braking detection
//   • TurnDetector integration — live turn counting
//   • TripTimerService wiring — starts/stops with telemetry
//   • DriveScoreEngine — computes score on trip completion
//   • All behavior data persisted inside Trip model

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import 'trip_storage_service.dart';
import 'garage_service.dart';
import 'drive_mode_service.dart';
import '../models/drive_mode.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'telemetry_analyzer.dart';
import 'turn_detector.dart';
import 'drive_score_engine.dart';
import 'trip_timer_service.dart';

class GpsService extends ChangeNotifier {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  StreamSubscription<Position>? _positionStreamSub;

  bool _isActive = false;
  bool get isActive => _isActive;

  // ─── Speed (EMA-smoothed) ─────────────────────────────────────────────────
  // α = 0.30 → heavier damping for vehicle-like feel; lower α = more smoothing
  static const double _emaAlpha = 0.30;

  double _smoothedSpeedKmh = 0.0;
  double _rawSpeedKmh      = 0.0;

  /// EMA-smoothed speed — drives the speedometer needle.
  double get currentSpeedKmh => _smoothedSpeedKmh;

  /// Raw GPS speed — used internally for precise analytics calculations.
  double get rawSpeedKmh => _rawSpeedKmh;

  // ─── Position & heading ───────────────────────────────────────────────────
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  double _currentHeading = 0.0;
  double get currentHeading => _currentHeading;

  // ─── Route & speed history ────────────────────────────────────────────────
  final List<LatLng> _routePoints   = [];
  final List<double> _speedSamples  = [];
  List<LatLng> get routePoints   => List.unmodifiable(_routePoints);
  List<double> get speedSamples  => List.unmodifiable(_speedSamples);

  // ─── Aggregate metrics ────────────────────────────────────────────────────
  double _maxGForce        = 0.0;
  double get maxGForce     => _maxGForce;

  double _topSpeed         = 0.0;
  double get topSpeed      => _topSpeed;

  double _totalDistanceKm  = 0.0;
  double get totalDistanceKm => _totalDistanceKm;

  DateTime? _startTime;

  // ─── Sub-services ─────────────────────────────────────────────────────────
  final TelemetryAnalyzer _analyzer    = TelemetryAnalyzer();
  final TurnDetector      _turnDetector = TurnDetector();
  final DriveScoreEngine  _scoreEngine  = DriveScoreEngine();

  StreamSubscription? _accelSub;

  // ─── Live behavior passthrough ────────────────────────────────────────────
  double get currentAccelMs2    => _analyzer.currentAccelMs2;
  bool   get isAccelerating     => _analyzer.isAccelerating;
  bool   get isBraking          => _analyzer.isBraking;
  int    get aggressiveAccelCount => _analyzer.aggressiveAccelCount;
  int    get smoothAccelCount     => _analyzer.smoothAccelCount;
  int    get harshBrakingCount    => _analyzer.harshBrakingCount;
  int    get smoothBrakingCount   => _analyzer.smoothBrakingCount;
  int    get leftTurnCount        => _turnDetector.leftTurnCount;
  int    get rightTurnCount       => _turnDetector.rightTurnCount;
  int    get sharpTurnCount       => _turnDetector.sharpTurnCount;

  // ─── Permissions ─────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  // ─── Telemetry lifecycle ──────────────────────────────────────────────────

  Future<void> startTelemetry() async {
    if (_isActive) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    // Reset all state
    _isActive           = true;
    _smoothedSpeedKmh   = 0.0;
    _rawSpeedKmh        = 0.0;
    _topSpeed           = 0.0;
    _totalDistanceKm    = 0.0;
    _currentHeading     = 0.0;
    _maxGForce          = 0.0;
    _routePoints.clear();
    _speedSamples.clear();
    _startTime = DateTime.now();

    // Reset sub-services
    _analyzer.reset();
    _turnDetector.fullReset();

    // Start timer
    TripTimerService().reset();
    TripTimerService().start();

    notifyListeners();

    _startGForceTracking();

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      final now = DateTime.now();

      // ── Raw speed ──
      double rawKmh = position.speed * 3.6;
      if (rawKmh < 0) rawKmh = 0.0;
      _rawSpeedKmh = rawKmh;

      // ── EMA smoothing ──
      // If the speed delta is < 0.5 km/h treat as jitter — hold previous value
      final double delta = (rawKmh - _smoothedSpeedKmh).abs();
      if (delta >= 0.5 || rawKmh == 0.0) {
        _smoothedSpeedKmh = _emaAlpha * rawKmh +
                            (1.0 - _emaAlpha) * _smoothedSpeedKmh;
      }

      if (_smoothedSpeedKmh < 0.3) _smoothedSpeedKmh = 0.0; // snap to zero

      // ── Top speed tracks raw (most accurate peak) ──
      if (rawKmh > _topSpeed) _topSpeed = rawKmh;

      // ── Heading ──
      if (position.heading >= 0) {
        _currentHeading = position.heading;
      }

      // ── Route & distance ──
      final latLng = LatLng(position.latitude, position.longitude);
      if (_routePoints.isNotEmpty) {
        final lastPoint = _routePoints.last;
        final distMeters = Geolocator.distanceBetween(
          lastPoint.latitude, lastPoint.longitude,
          latLng.latitude,   latLng.longitude,
        );
        _totalDistanceKm += (distMeters / 1000.0);
      }
      _routePoints.add(latLng);
      _speedSamples.add(_smoothedSpeedKmh);

      // ── Feed analytics (uses smoothed speed for accel/brake smoothness) ──
      _analyzer.processSample(_smoothedSpeedKmh, now);

      // ── Feed turn detector (uses raw heading, min speed guard inside) ──
      _turnDetector.processHeading(_currentHeading, rawKmh, now);


      notifyListeners();
    });
  }

  void stopTelemetry() {
    if (!_isActive) return;

    _accelSub?.cancel();
    _accelSub = null;

    // Stop timer and capture elapsed seconds
    TripTimerService().stop();
    final int elapsedSeconds = TripTimerService().elapsedSeconds;

    if (_startTime != null && _routePoints.isNotEmpty) {
      final activeVehicleId = GarageService().activeVehicleId;
      final currentMode     = DriveModeService().currentMode;

      // Baseline expected duration
      double baselineSpeed = 45.0;
      if (currentMode == DriveMode.sport)     baselineSpeed = 55.0;
      if (currentMode == DriveMode.sportPlus) baselineSpeed = 65.0;

      final expectedMins = _totalDistanceKm > 0
          ? (_totalDistanceKm / baselineSpeed * 60).round().clamp(1, 1440)
          : 0;

      final double avgSpeedKmh = elapsedSeconds > 0
          ? (_totalDistanceKm / (elapsedSeconds / 3600.0))
          : 0.0;

      // Compute drive score
      final int score = _scoreEngine.calculateScore(
        harshBrakingCount:    _analyzer.harshBrakingCount,
        aggressiveAccelCount: _analyzer.aggressiveAccelCount,
        smoothAccelCount:     _analyzer.smoothAccelCount,
        sharpTurnCount:       _turnDetector.sharpTurnCount,
        topSpeedKmh:          _topSpeed,
        maxGForce:            _maxGForce,
        avgSpeedKmh:          avgSpeedKmh,
      );

      final trip = Trip(
        id:                    const Uuid().v4(),
        vehicleId:             activeVehicleId,
        driveMode:             currentMode,
        startTime:             _startTime!,
        endTime:               DateTime.now(),
        distanceKm:            _totalDistanceKm,
        topSpeedKmh:           _topSpeed,
        routePoints:           List.from(_routePoints),
        speedSamples:          List.from(_speedSamples),
        expectedDurationMinutes: expectedMins > 0 ? expectedMins : null,
        maxGForce:             _maxGForce,
        // Behavior analytics
        aggressiveAccelCount:  _analyzer.aggressiveAccelCount,
        smoothAccelCount:      _analyzer.smoothAccelCount,
        harshBrakingCount:     _analyzer.harshBrakingCount,
        smoothBrakingCount:    _analyzer.smoothBrakingCount,
        leftTurnCount:         _turnDetector.leftTurnCount,
        rightTurnCount:        _turnDetector.rightTurnCount,
        sharpTurnCount:        _turnDetector.sharpTurnCount,
        durationSeconds:       elapsedSeconds,
        driveScore:            score,
      );

      TripStorageService().saveTrip(trip);
    }

    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _isActive         = false;
    _smoothedSpeedKmh = 0.0;
    _rawSpeedKmh      = 0.0;
    notifyListeners();
  }

  // ─── G-Force tracking ─────────────────────────────────────────────────────

  void _startGForceTracking() {
    _accelSub = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!_isActive) return;
      final double magnitude = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      final double gForce = magnitude / 9.8;
      if (gForce > _maxGForce) {
        _maxGForce = gForce;
        notifyListeners();
      }
    });
  }

  // ─── Duration helper (for HUD display) ───────────────────────────────────

  int get tripDurationMinutes {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inMinutes;
  }
}
