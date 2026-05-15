import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import 'trip_storage_service.dart';

class GpsService extends ChangeNotifier {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  StreamSubscription<Position>? _positionStreamSub;
  
  bool _isActive = false;
  bool get isActive => _isActive;

  double _currentSpeedKmh = 0.0;
  double get currentSpeedKmh => _currentSpeedKmh;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  final List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  double _topSpeed = 0.0;
  double get topSpeed => _topSpeed;
  
  double _totalDistanceKm = 0.0;
  double get totalDistanceKm => _totalDistanceKm;
  
  DateTime? _startTime;

  Future<bool> requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Location services are disabled.
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Permissions are denied.
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false; // Permissions are permanently denied.
    }

    return true;
  }

  Future<void> startTelemetry() async {
    if (_isActive) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    _isActive = true;
    _currentSpeedKmh = 0.0;
    _topSpeed = 0.0;
    _totalDistanceKm = 0.0;
    _routePoints.clear();
    _startTime = DateTime.now();
    notifyListeners();

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, // Updates as fast as hardware allows
      ),
    ).listen((Position position) {
      _currentPosition = position;
      
      // Speed is provided in m/s, convert to km/h
      double speedKmh = position.speed * 3.6;
      if (speedKmh < 0) speedKmh = 0.0;
      
      _currentSpeedKmh = speedKmh;
      if (speedKmh > _topSpeed) _topSpeed = speedKmh;

      final latLng = LatLng(position.latitude, position.longitude);
      
      if (_routePoints.isNotEmpty) {
        final lastPoint = _routePoints.last;
        final distMeters = Geolocator.distanceBetween(
          lastPoint.latitude, lastPoint.longitude,
          latLng.latitude, latLng.longitude,
        );
        _totalDistanceKm += (distMeters / 1000.0);
      }

      _routePoints.add(latLng);
      notifyListeners();
    });
  }

  void stopTelemetry() {
    if (!_isActive) return;
    
    // Save the trip before clearing
    if (_startTime != null && _routePoints.isNotEmpty) {
      final trip = Trip(
        id: const Uuid().v4(),
        startTime: _startTime!,
        endTime: DateTime.now(),
        distanceKm: _totalDistanceKm,
        topSpeedKmh: _topSpeed,
        routePoints: List.from(_routePoints),
      );
      TripStorageService().saveTrip(trip);
    }

    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _isActive = false;
    _currentSpeedKmh = 0.0;
    notifyListeners();
  }

  int get tripDurationMinutes {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inMinutes;
  }
}
