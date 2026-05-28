import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'drive_mode.dart';
import '../services/drive_score_engine.dart';

class Trip {
  final String id;
  final String? vehicleId;
  final DriveMode driveMode;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final double topSpeedKmh;
  final List<LatLng> routePoints;
  final List<double> speedSamples;
  final int? expectedDurationMinutes;
  final double maxGForce;

  // ─── Behavior analytics (new — backward compatible, default 0) ───────────
  final int aggressiveAccelCount;
  final int smoothAccelCount;
  final int harshBrakingCount;
  final int smoothBrakingCount;
  final int leftTurnCount;
  final int rightTurnCount;
  final int sharpTurnCount;

  /// Precise trip duration in seconds from the Stopwatch timer.
  final int durationSeconds;

  /// Pre-computed drive score stored per trip (0–100).
  /// Stored so it's consistent across app restarts (no recalculation drift).
  final int driveScore;

  Trip({
    required this.id,
    this.vehicleId,
    this.driveMode = DriveMode.sport,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.topSpeedKmh,
    required this.routePoints,
    this.speedSamples = const [],
    this.expectedDurationMinutes,
    this.maxGForce = 0.0,
    // Behavior analytics
    this.aggressiveAccelCount = 0,
    this.smoothAccelCount     = 0,
    this.harshBrakingCount    = 0,
    this.smoothBrakingCount   = 0,
    this.leftTurnCount        = 0,
    this.rightTurnCount       = 0,
    this.sharpTurnCount       = 0,
    this.durationSeconds      = 0,
    this.driveScore           = 0,
  });

  // ─── Duration helpers ─────────────────────────────────────────────────────

  /// Duration in minutes (derived from actual endTime−startTime).
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Precise duration — prefer Stopwatch seconds if available, fall back to diff.
  int get preciseDurationSeconds =>
      durationSeconds > 0 ? durationSeconds : endTime.difference(startTime).inSeconds;

  /// Formatted MM:SS or HH:MM:SS from precise seconds.
  String get formattedDuration {
    final int total = preciseDurationSeconds;
    final int h = total ~/ 3600;
    final int m = (total % 3600) ~/ 60;
    final int s = total % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
             '${m.toString().padLeft(2, '0')}:'
             '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
           '${s.toString().padLeft(2, '0')}';
  }

  int get displayExpectedMinutes {
    if (expectedDurationMinutes != null && expectedDurationMinutes! > 0) {
      return expectedDurationMinutes!;
    }
    double baselineSpeed = 45.0;
    if (driveMode == DriveMode.sport) baselineSpeed = 55.0;
    if (driveMode == DriveMode.sportPlus) baselineSpeed = 65.0;

    final calc = (distanceKm / baselineSpeed * 60).round();
    return calc > 0 ? calc : 1;
  }

  DateTime get estimatedArrivalTime => startTime.add(Duration(minutes: displayExpectedMinutes));
  DateTime get actualArrivalTime    => endTime;

  double get averageSpeedKmh {
    final hours = durationMinutes / 60.0;
    return hours > 0 ? (distanceKm / hours) : 0.0;
  }

  // ─── Score getters (for backward-compat analytics rings) ─────────────────

  /// Returns stored driveScore; if legacy trip (driveScore==0), compute fallback.
  int get tripScore {
    if (driveScore > 0) return driveScore;
    // Legacy fallback for trips recorded before this upgrade
    return DriveScoreEngine().calculateScore(
      harshBrakingCount:     harshBrakingCount,
      aggressiveAccelCount:  aggressiveAccelCount,
      smoothAccelCount:      smoothAccelCount,
      sharpTurnCount:        sharpTurnCount,
      topSpeedKmh:           topSpeedKmh,
      maxGForce:             maxGForce,
      avgSpeedKmh:           averageSpeedKmh,
    );
  }

  /// Smoothness score based on G-Force and braking events.
  int get smoothScore {
    double s = 100.0;
    s -= maxGForce * 12;
    s -= harshBrakingCount * 5.0;
    if (!s.isFinite) return 0;
    return s.round().clamp(0, 100);
  }

  /// Speed score: penalty above 100 km/h top speed.
  int get speedScore {
    final double s = 100 - (topSpeedKmh > 100 ? (topSpeedKmh - 100) : 0);
    if (!s.isFinite) return 0;
    return s.round().clamp(0, 100);
  }

  /// Efficiency score relative to expected vs actual duration.
  int get efficiencyScore {
    if (distanceKm == 0 || durationMinutes <= 0) return 100;
    final double ratio = displayExpectedMinutes / durationMinutes;
    if (!ratio.isFinite) return 100;
    return (ratio * 100).round().clamp(0, 100);
  }

  /// Braking quality score.
  int get brakeScore {
    final int total = harshBrakingCount + smoothBrakingCount;
    if (total == 0) return 100;
    final double ratio = smoothBrakingCount / total;
    return (ratio * 100).round().clamp(0, 100);
  }

  /// Acceleration quality score.
  int get accelScore {
    final int total = aggressiveAccelCount + smoothAccelCount;
    if (total == 0) return 100;
    final double ratio = smoothAccelCount / total;
    return (ratio * 100).round().clamp(0, 100);
  }

  // ─── Serialization ────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id':                    id,
      'vehicleId':             vehicleId,
      'driveMode':             driveMode.index,
      'startTime':             startTime.toIso8601String(),
      'endTime':               endTime.toIso8601String(),
      'distanceKm':            distanceKm,
      'topSpeedKmh':           topSpeedKmh,
      'routePoints':           routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'speedSamples':          speedSamples,
      'expectedDurationMinutes': expectedDurationMinutes,
      'maxGForce':             maxGForce,
      // Behavior fields
      'aggressiveAccelCount':  aggressiveAccelCount,
      'smoothAccelCount':      smoothAccelCount,
      'harshBrakingCount':     harshBrakingCount,
      'smoothBrakingCount':    smoothBrakingCount,
      'leftTurnCount':         leftTurnCount,
      'rightTurnCount':        rightTurnCount,
      'sharpTurnCount':        sharpTurnCount,
      'durationSeconds':       durationSeconds,
      'driveScore':            driveScore,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id:             map['id'],
      vehicleId:      map['vehicleId'],
      driveMode:      DriveMode.values[map['driveMode'] ?? DriveMode.sport.index],
      startTime:      DateTime.parse(map['startTime']),
      endTime:        DateTime.parse(map['endTime']),
      distanceKm:     map['distanceKm']?.toDouble() ?? 0.0,
      topSpeedKmh:    map['topSpeedKmh']?.toDouble() ?? 0.0,
      routePoints:    (map['routePoints'] as List?)
                          ?.map((p) => LatLng(p['lat'], p['lng'])).toList() ?? [],
      speedSamples:   (map['speedSamples'] as List?)
                          ?.map((s) => (s as num).toDouble()).toList() ?? [],
      expectedDurationMinutes: map['expectedDurationMinutes'],
      maxGForce:      map['maxGForce']?.toDouble() ?? 0.0,
      // Behavior fields — default 0 for backward compatibility with old trips
      aggressiveAccelCount:  map['aggressiveAccelCount'] as int? ?? 0,
      smoothAccelCount:      map['smoothAccelCount']     as int? ?? 0,
      harshBrakingCount:     map['harshBrakingCount']    as int? ?? 0,
      smoothBrakingCount:    map['smoothBrakingCount']   as int? ?? 0,
      leftTurnCount:         map['leftTurnCount']        as int? ?? 0,
      rightTurnCount:        map['rightTurnCount']       as int? ?? 0,
      sharpTurnCount:        map['sharpTurnCount']       as int? ?? 0,
      durationSeconds:       map['durationSeconds']      as int? ?? 0,
      driveScore:            map['driveScore']           as int? ?? 0,
    );
  }

  String toJson()                      => json.encode(toMap());
  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));
}
