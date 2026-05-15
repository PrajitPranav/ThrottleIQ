import 'dart:convert';

class Vehicle {
  final String id;
  final String make;
  final String model;
  final String? imagePath;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    this.imagePath,
  });

  String get displayName => '$make $model';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'imagePath': imagePath,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      imagePath: map['imagePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) => Vehicle.fromMap(json.decode(source));
}
