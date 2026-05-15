// drive_mode.dart — DriveMode enum with elegant theme data.

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

  // Primary accent color for this mode (muted, elegant)
  Color get accent {
    switch (this) {
      case DriveMode.eco:      return const Color(0xFF5A7D65); // sage green
      case DriveMode.comfort:  return const Color(0xFF4F6B8F); // slate blue
      case DriveMode.sport:    return const Color(0xFF9E653F); // muted amber
      case DriveMode.sportPlus: return const Color(0xFF8F3232); // deep red
    }
  }

  // Soft ambient glow color (extremely low alpha for minimalism)
  Color get glow {
    switch (this) {
      case DriveMode.eco:      return const Color(0x0C5A7D65);
      case DriveMode.comfort:  return const Color(0x0C4F6B8F);
      case DriveMode.sport:    return const Color(0x129E653F);
      case DriveMode.sportPlus: return const Color(0x158F3232);
    }
  }

  // Background radial gradient overlay color (barely visible)
  Color get bgOverlay {
    switch (this) {
      case DriveMode.eco:      return const Color(0x065A7D65);
      case DriveMode.comfort:  return const Color(0x064F6B8F);
      case DriveMode.sport:    return const Color(0x0A9E653F);
      case DriveMode.sportPlus: return const Color(0x0D8F3232);
    }
  }
}
