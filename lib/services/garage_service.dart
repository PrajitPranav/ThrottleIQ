import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/drive_mode.dart';
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
    _activeVehicleId ??= vehicle.id;
    await _save();
    notifyListeners();
  }

  Future<void> selectVehicle(String id) async {
    _activeVehicleId = id;
    notifyListeners(); // Update UI immediately — don't wait on disk I/O
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeVehicleKey, id);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> vehicleJsonList = _vehicles.map((v) => v.toJson()).toList();
    await prefs.setStringList(_vehiclesKey, vehicleJsonList);
    if (_activeVehicleId != null) {
      await prefs.setString(_activeVehicleKey, _activeVehicleId!);
    }
  }

  // Update manual stat overrides for a vehicle
  Future<void> updateVehicleStats(String vehicleId, {double? distanceKm, double? topSpeedKmh}) async {
    final idx = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (idx == -1) return;
    _vehicles[idx] = _vehicles[idx].copyWith(
      manualDistanceKm: distanceKm ?? _vehicles[idx].manualDistanceKm,
      manualTopSpeedKmh: topSpeedKmh ?? _vehicles[idx].manualTopSpeedKmh,
    );
    await _save();
    notifyListeners();
  }

  // Aggregated Stats for a specific vehicle
  Map<String, dynamic> getVehicleStats(String vehicleId) {
    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId, orElse: () => Vehicle(id: vehicleId, make: '', model: ''));
    final trips = TripStorageService().trips.where((t) => t.vehicleId == vehicleId).toList();
    
    if (trips.isEmpty) {
      return {
        'totalTrips': 0,
        'totalDistanceKm': vehicle.manualDistanceKm,
        'avgSpeedKmh': 0.0,
        'topSpeedKmh': vehicle.manualTopSpeedKmh,
        'totalDurationMinutes': 0,
        'favoriteMode': null,
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

    // Calculate favorite mode
    final Map<DriveMode, int> modeCounts = {};
    for (var trip in trips) {
      modeCounts[trip.driveMode] = (modeCounts[trip.driveMode] ?? 0) + 1;
    }
    final favoriteMode = modeCounts.entries.isEmpty 
        ? DriveMode.sport 
        : modeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalTrips': trips.length,
      'totalDistanceKm': totalDist + vehicle.manualDistanceKm,
      'avgSpeedKmh': avgSpeed,
      'topSpeedKmh': vehicle.manualTopSpeedKmh > topSpeed ? vehicle.manualTopSpeedKmh : topSpeed,
      'totalDurationMinutes': totalDuration,
      'favoriteMode': favoriteMode,
    };
  }
}
