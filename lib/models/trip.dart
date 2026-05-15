import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String id;
  final String? vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final double topSpeedKmh;
  final List<LatLng> routePoints;
  final List<double> speedSamples;
  final int? expectedDurationMinutes;

  Trip({
    required this.id,
    this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.topSpeedKmh,
    required this.routePoints,
    this.speedSamples = const [],
    this.expectedDurationMinutes,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;
  
  double get averageSpeedKmh {
    final hours = durationMinutes / 60.0;
    return hours > 0 ? (distanceKm / hours) : 0.0;
  }

  int get tripScore {
    int score = 100;
    if (topSpeedKmh > 120) score -= 10;
    if (averageSpeedKmh > 80) score -= 5;
    return score.clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distanceKm': distanceKm,
      'topSpeedKmh': topSpeedKmh,
      'routePoints': routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'speedSamples': speedSamples,
      'expectedDurationMinutes': expectedDurationMinutes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      vehicleId: map['vehicleId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distanceKm: map['distanceKm']?.toDouble() ?? 0.0,
      topSpeedKmh: map['topSpeedKmh']?.toDouble() ?? 0.0,
      routePoints: (map['routePoints'] as List?)?.map((p) => LatLng(p['lat'], p['lng'])).toList() ?? [],
      speedSamples: (map['speedSamples'] as List?)?.map((s) => (s as num).toDouble()).toList() ?? [],
      expectedDurationMinutes: map['expectedDurationMinutes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));
}
