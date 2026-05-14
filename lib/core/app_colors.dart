// app_colors.dart — Central color palette for ThrottleIQ
//
// All colors used across the app are defined here.
// This makes it easy to keep the design consistent and update the palette later.

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor so this class can never be instantiated
  AppColors._();

  // --- Background Layers ---
  static const Color backgroundDeep    = Color(0xFF060608); // Deepest black (body bg)
  static const Color backgroundSurface = Color(0xFF0D0D10); // Gauge face background
  static const Color backgroundPanel   = Color(0xFF111116); // Info panels

  // --- Gauge Chrome / Ring ---
  static const Color chromeOuter       = Color(0xFF2A2A30); // Outer bezel ring dark
  static const Color chromeInner       = Color(0xFF1A1A1F); // Inner ring
  static const Color chromeMid         = Color(0xFF222228); // Middle chrome band
  static const Color chromeScratch     = Color(0xFF3A3A42); // Brushed highlight

  // --- Tick Marks ---
  static const Color tickMajor         = Color(0xFFCCCCCC); // Major tick (bright white)
  static const Color tickMinor         = Color(0xFF555560); // Minor tick (dim)
  static const Color tickRedZone       = Color(0xFFCC2200); // Major tick in red zone

  // --- Speed Arc Zones ---
  static const Color arcGreen          = Color(0xFF1DB954); // 0–80: normal
  static const Color arcAmber          = Color(0xFFFF8C00); // 80–160: sport
  static const Color arcRed            = Color(0xFFCC2200); // 160–240: danger

  // --- Arc Track ---
  static const Color arcTrack          = Color(0xFF1A1A22); // Inactive arc background

  // --- Needle ---
  static const Color needleBody        = Color(0xFFE8E8EC); // Polished silver needle
  static const Color needleTip         = Color(0xFFFF2200); // Red hot tip
  static const Color needleKnob        = Color(0xFF1A1A1F); // Pivot cap
  static const Color needleKnobRing    = Color(0xFFCC2200); // Red ring on pivot
  static const Color needleTail        = Color(0xFF333340); // Tail counterweight

  // --- Center Display Typography ---
  static const Color speedDigit        = Color(0xFFF0F0F5); // Large speed number
  static const Color speedUnit         = Color(0xFF666670); // "KM/H" label
  static const Color driveMode         = Color(0xFFCC2200); // Drive mode text (SPORT)

  // --- UI Controls ---
  static const Color btnActiveBorder   = Color(0xFFCC2200);
  static const Color btnActiveGlow     = Color(0x33CC2200);
  static const Color btnInactiveBorder = Color(0xFF222228);
  static const Color btnInactiveFill   = Color(0xFF0F0F13);
  static const Color btnText           = Color(0xFFAAAAAA);

  // --- Status Indicator ---
  static const Color statusActive      = Color(0xFFCC2200);
  static const Color statusIdle        = Color(0xFF333340);

  // --- Ambient Glow ---
  static const Color glowRed           = Color(0x44CC2200); // Subtle red ambient
  static const Color glowAmber         = Color(0x33FF8C00); // Amber glow at high speed
}
