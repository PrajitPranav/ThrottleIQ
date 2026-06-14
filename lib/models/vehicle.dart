import 'dart:convert';

class Vehicle {
  final String id;
  final String make;
  final String model;
  final String? imagePath;
  // Manual stat overrides (added by user in Garage)
  final double manualDistanceKm;
  final double manualTopSpeedKmh;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    this.imagePath,
    this.manualDistanceKm = 0.0,
    this.manualTopSpeedKmh = 0.0,
  });

  Vehicle copyWith({
    double? manualDistanceKm,
    double? manualTopSpeedKmh,
  }) {
    return Vehicle(
      id: id,
      make: make,
      model: model,
      imagePath: imagePath,
      manualDistanceKm: manualDistanceKm ?? this.manualDistanceKm,
      manualTopSpeedKmh: manualTopSpeedKmh ?? this.manualTopSpeedKmh,
    );
  }

  String get displayName => '$make $model';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'imagePath': imagePath,
      'manualDistanceKm': manualDistanceKm,
      'manualTopSpeedKmh': manualTopSpeedKmh,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      imagePath: map['imagePath'],
      manualDistanceKm: (map['manualDistanceKm'] as num?)?.toDouble() ?? 0.0,
      manualTopSpeedKmh: (map['manualTopSpeedKmh'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) => Vehicle.fromMap(json.decode(source));
}
