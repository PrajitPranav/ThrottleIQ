import 'package:flutter/foundation.dart';
import '../models/drive_mode.dart';

class DriveModeService extends ChangeNotifier {
  static final DriveModeService _instance = DriveModeService._internal();
  factory DriveModeService() => _instance;
  DriveModeService._internal();

  DriveMode _currentMode = DriveMode.sport;
  DriveMode get currentMode => _currentMode;

  void setMode(DriveMode mode) {
    if (_currentMode == mode) return;
    _currentMode = mode;
    notifyListeners();
  }
}
