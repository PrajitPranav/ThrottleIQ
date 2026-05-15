import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class TripStorageService extends ChangeNotifier {
  static final TripStorageService _instance = TripStorageService._internal();
  factory TripStorageService() => _instance;
  TripStorageService._internal();

  static const String _storageKey = 'throttleiq_trips';
  List<Trip> _trips = [];

  List<Trip> get trips => List.unmodifiable(_trips);

  Future<void> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tripJsonList = prefs.getStringList(_storageKey);
    
    if (tripJsonList != null) {
      _trips = tripJsonList.map((jsonStr) => Trip.fromJson(jsonStr)).toList();
      // Sort by start time descending
      _trips.sort((a, b) => b.startTime.compareTo(a.startTime));
      notifyListeners();
    }
  }

  Future<void> saveTrip(Trip trip) async {
    _trips.add(trip);
    _trips.sort((a, b) => b.startTime.compareTo(a.startTime));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    _trips.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tripJsonList = _trips.map((t) => t.toJson()).toList();
    await prefs.setStringList(_storageKey, tripJsonList);
  }

  Future<void> clearAll() async {
    _trips.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
