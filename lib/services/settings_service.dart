import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _useMetricKey = 'use_metric';
  static const String _notificationsKey = 'notifications_enabled';

  bool _useMetric = true;
  bool get useMetric => _useMetric;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useMetric = prefs.getBool(_useMetricKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setUseMetric(bool value) async {
    _useMetric = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMetricKey, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    notifyListeners();
  }

  // Unit Labels
  String get speedUnit => _useMetric ? 'KM/H' : 'MPH';
  String get distanceUnit => _useMetric ? 'KM' : 'MI';

  // Conversion logic
  double convertSpeed(double kmph) => _useMetric ? kmph : kmph * 0.621371;
  double convertDistance(double km) => _useMetric ? km : km * 0.621371;
  
  String formatSpeed(double kmph) => convertSpeed(kmph).toStringAsFixed(0);
  String formatDistance(double km) => convertDistance(km).toStringAsFixed(1);
}
