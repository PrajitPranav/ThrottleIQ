// app_colors.dart — Central color palette for ThrottleIQ
//
// All colors used across the app are defined here.
// This makes it easy to keep the design consistent and update the palette.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color backgroundDeep    = Color(0xFF050507);
  static const Color backgroundSurface = Color(0xFF0B0B0F);
  static const Color backgroundPanel   = Color(0xFF0F0F14);

  // ─── Chrome / Bezel ──────────────────────────────────────────────────────────
  static const Color chromeOuter       = Color(0xFF252528);
  static const Color chromeMid         = Color(0xFF1C1C20);
  static const Color chromeInner       = Color(0xFF161618);
  static const Color chromeScratch     = Color(0xFF3C3C44); // brushed highlight
  static const Color chromeHighlight   = Color(0xFF5A5A64); // specular glint

  // ─── Arc Track ───────────────────────────────────────────────────────────────
  static const Color arcTrack          = Color(0xFF141418);

  // ─── Speed Zone Arcs ─────────────────────────────────────────────────────────
  // Porsche-inspired: blue-white normal, amber sport, vivid red danger
  static const Color arcNormal         = Color(0xFF4A9ECC); // 0–160: cool blue-white
  static const Color arcSport          = Color(0xFFE08020); // 160–250: amber
  static const Color arcDanger         = Color(0xFFCC1800); // 250–300: hard red

  // ─── Tick Marks ──────────────────────────────────────────────────────────────
  static const Color tickMajor         = Color(0xFFD8D8DC); // crisp white
  static const Color tickMinor         = Color(0xFF484850); // dark grey
  static const Color tickSport         = Color(0xFFE08020); // amber zone ticks
  static const Color tickDanger        = Color(0xFFCC1800); // red zone ticks

  // ─── Needle ──────────────────────────────────────────────────────────────────
  static const Color needleBase        = Color(0xFFFF6600); // base orange
  static const Color needleTip         = Color(0xFFFF1100); // hot red tip
  static const Color needleShaft       = Color(0xFFFF4400); // mid shaft
  static const Color needleKnobCenter  = Color(0xFF0E0E12);
  static const Color needleKnobRing    = Color(0xFFCC1800);
  static const Color needleTail        = Color(0xFF2A2A32);

  // ─── Center Display ──────────────────────────────────────────────────────────
  static const Color speedDigit        = Color(0xFFF4F4F8);
  static const Color speedUnit         = Color(0xFF5A5A66);
  static const Color driveMode         = Color(0xFFCC1800);
  static const Color driveModeComfort  = Color(0xFF4A9ECC);
  static const Color driveModeSport    = Color(0xFFE08020);

  // ─── UI Controls ─────────────────────────────────────────────────────────────
  static const Color btnActiveBorder   = Color(0xFFCC1800);
  static const Color btnInactiveBorder = Color(0xFF1E1E24);
  static const Color btnInactiveFill   = Color(0xFF0C0C10);

  // ─── Status & Indicators ─────────────────────────────────────────────────────
  static const Color statusActive      = Color(0xFFCC1800);
  static const Color statusIdle        = Color(0xFF2C2C38);

  // ─── Ambient Glow ────────────────────────────────────────────────────────────
  static const Color glowRed           = Color(0x55CC1800);
  static const Color glowAmber         = Color(0x44E08020);
  static const Color glowBlue          = Color(0x334A9ECC);
}
