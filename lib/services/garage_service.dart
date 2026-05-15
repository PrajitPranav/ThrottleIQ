import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/trip.dart';
import 'trip_storage_service.dart';

class GarageService extends ChangeNotifier {
  static final GarageService _instance = GarageService._internal();
  factory GarageService() => _instance;
  GarageService._internal();

  static const String _vehiclesKey = 'throttleiq_vehicles';
  static const String _activeVehicleKey = 'throttleiq_active_vehicle';

  List<Vehicle> _vehicles = [];
  String? _activeVehicleId;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  String? get activeVehicleId => _activeVehicleId;
  
  Vehicle? get activeVehicle {
    if (_activeVehicleId == null) return null;
    return _vehicles.firstWhere((v) => v.id == _activeVehicleId, orElse: () => _vehicles.first);
  }

  Future<void> loadGarage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? vehicleJsonList = prefs.getStringList(_vehiclesKey);
    _activeVehicleId = prefs.getString(_activeVehicleKey);
    
    if (vehicleJsonList != null) {
      _vehicles = vehicleJsonList.map((jsonStr) => Vehicle.fromJson(jsonStr)).toList();
      
      if (_activeVehicleId == null && _vehicles.isNotEmpty) {
        _activeVehicleId = _vehicles.first.id;
      }
      notifyListeners();
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    if (_activeVehicleId == null) {
      _activeVehicleId = vehicle.id;
    }
    await _save();
    notifyListeners();
  }

  Future<void> selectVehicle(String id) async {
    _activeVehicleId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeVehicleKey, id);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> vehicleJsonList = _vehicles.map((v) => v.toJson()).toList();
    await prefs.setStringList(_vehiclesKey, vehicleJsonList);
    if (_activeVehicleId != null) {
      await prefs.setString(_activeVehicleKey, _activeVehicleId!);
    }
  }

  // Aggregated Stats for a specific vehicle
  Map<String, dynamic> getVehicleStats(String vehicleId) {
    final trips = TripStorageService().trips.where((t) => t.vehicleId == vehicleId).toList();
    
    if (trips.isEmpty) {
      return {
        'totalTrips': 0,
        'totalDistanceKm': 0.0,
        'avgSpeedKmh': 0.0,
        'topSpeedKmh': 0.0,
        'totalDurationMinutes': 0,
      };
    }

    double totalDist = 0.0;
    double topSpeed = 0.0;
    int totalDuration = 0;

    for (var trip in trips) {
      totalDist += trip.distanceKm;
      if (trip.topSpeedKmh > topSpeed) topSpeed = trip.topSpeedKmh;
      totalDuration += trip.durationMinutes;
    }

    double avgSpeed = totalDuration > 0 ? (totalDist / (totalDuration / 60.0)) : 0.0;

    return {
      'totalTrips': trips.length,
      'totalDistanceKm': totalDist,
      'avgSpeedKmh': avgSpeed,
      'topSpeedKmh': topSpeed,
      'totalDurationMinutes': totalDuration,
    };
  }
}
