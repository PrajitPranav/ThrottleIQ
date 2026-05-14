// drive_mode.dart — DriveMode enum with associated theme data.

import 'package:flutter/material.dart';

enum DriveMode { eco, comfort, sport, sportPlus }

extension DriveModeX on DriveMode {
  String get label {
    switch (this) {
      case DriveMode.eco:      return 'ECO';
      case DriveMode.comfort:  return 'COMFORT';
      case DriveMode.sport:    return 'SPORT';
      case DriveMode.sportPlus: return 'SPORT+';
    }
  }

  // Primary accent color for this mode
  Color get accent {
    switch (this) {
      case DriveMode.eco:      return const Color(0xFF26A65B);
      case DriveMode.comfort:  return const Color(0xFF4A9ECC);
      case DriveMode.sport:    return const Color(0xFFE08020);
      case DriveMode.sportPlus: return const Color(0xFFCC1800);
    }
  }

  // Soft ambient glow color (low alpha)
  Color get glow {
    switch (this) {
      case DriveMode.eco:      return const Color(0x2226A65B);
      case DriveMode.comfort:  return const Color(0x224A9ECC);
      case DriveMode.sport:    return const Color(0x33E08020);
      case DriveMode.sportPlus: return const Color(0x44CC1800);
    }
  }

  // Background radial gradient overlay color
  Color get bgOverlay {
    switch (this) {
      case DriveMode.eco:      return const Color(0x1126A65B);
      case DriveMode.comfort:  return const Color(0x114A9ECC);
      case DriveMode.sport:    return const Color(0x18E08020);
      case DriveMode.sportPlus: return const Color(0x22CC1800);
    }
  }
}
