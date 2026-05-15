import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final double topSpeedKmh;
  final List<LatLng> routePoints;

  Trip({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.topSpeedKmh,
    required this.routePoints,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;
  
  double get averageSpeedKmh {
    final hours = durationMinutes / 60.0;
    return hours > 0 ? (distanceKm / hours) : 0.0;
  }

  // A basic score logic based on top speed vs avg speed
  int get tripScore {
    int score = 100;
    if (topSpeedKmh > 120) score -= 10;
    if (averageSpeedKmh > 80) score -= 5;
    return score.clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distanceKm': distanceKm,
      'topSpeedKmh': topSpeedKmh,
      'routePoints': routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distanceKm: map['distanceKm'],
      topSpeedKmh: map['topSpeedKmh'],
      routePoints: (map['routePoints'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));
}
