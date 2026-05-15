import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'drive_mode.dart';

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
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;
  
  double get averageSpeedKmh {
    final hours = durationMinutes / 60.0;
    return hours > 0 ? (distanceKm / hours) : 0.0;
  }

  int get tripScore {
    double score = 100.0;
    
    // Penalty for extreme speeding (> 120 km/h)
    if (topSpeedKmh > 120) score -= (topSpeedKmh - 120) * 0.5;
    
    // Penalty for high G-Force (aggressive driving)
    if (maxGForce > 0.8) score -= (maxGForce - 0.8) * 20;
    
    // Efficiency penalty (too slow might mean traffic, but too fast is aggressive)
    // Sweet spot: 40-70 km/h average
    if (averageSpeedKmh > 90) score -= (averageSpeedKmh - 90) * 0.3;
    if (averageSpeedKmh < 20 && distanceKm > 1.0) score -= (20 - averageSpeedKmh) * 0.5;

    return score.round().clamp(0, 100);
  }

  // Individual component scores (for breakdown)
  int get smoothScore => (100 - (maxGForce * 15)).round().clamp(0, 100);
  int get speedScore => (100 - (topSpeedKmh > 100 ? (topSpeedKmh - 100) : 0)).round().clamp(0, 100);
  int get efficiencyScore {
    if (distanceKm == 0) return 0;
    final double ratio = (expectedDurationMinutes ?? durationMinutes) / durationMinutes;
    return (ratio * 100).round().clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driveMode': driveMode.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distanceKm': distanceKm,
      'topSpeedKmh': topSpeedKmh,
      'routePoints': routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'speedSamples': speedSamples,
      'expectedDurationMinutes': expectedDurationMinutes,
      'maxGForce': maxGForce,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      vehicleId: map['vehicleId'],
      driveMode: DriveMode.values[map['driveMode'] ?? DriveMode.sport.index],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distanceKm: map['distanceKm']?.toDouble() ?? 0.0,
      topSpeedKmh: map['topSpeedKmh']?.toDouble() ?? 0.0,
      routePoints: (map['routePoints'] as List?)?.map((p) => LatLng(p['lat'], p['lng'])).toList() ?? [],
      speedSamples: (map['speedSamples'] as List?)?.map((s) => (s as num).toDouble()).toList() ?? [],
      expectedDurationMinutes: map['expectedDurationMinutes'],
      maxGForce: map['maxGForce']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));
}
