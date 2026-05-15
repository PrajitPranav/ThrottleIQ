// app_colors.dart — Premium minimalist color palette for ThrottleIQ
//
// A refined, elegant, and realistic automotive color system.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds ─────────────────────────────────────────────────────────────
  // Matte, realistic dark surfaces. No heavy blue/purple tints.
  static const Color backgroundDeep    = Color(0xFF040404);
  static const Color backgroundSurface = Color(0xFF0A0A0C);
  static const Color backgroundPanel   = Color(0xFF101014);

  // ─── Chrome / Bezel ──────────────────────────────────────────────────────────
  // Subdued, milled aluminum look rather than shiny chrome.
  static const Color chromeOuter       = Color(0xFF1E1E22);
  static const Color chromeMid         = Color(0xFF18181A);
  static const Color chromeInner       = Color(0xFF121214);
  static const Color chromeScratch     = Color(0xFF2C2C32); // brushed highlight
  static const Color chromeHighlight   = Color(0xFF4A4A52); // specular glint

  // ─── Arc Track ───────────────────────────────────────────────────────────────
  static const Color arcTrack          = Color(0xFF141416);

  // ─── Speed Zone Arcs ─────────────────────────────────────────────────────────
  // Muted, elegant track accents. NOT glowing neon.
  static const Color arcNormal         = Color(0xFF4F6B8F); // 0–160: muted slate blue
  static const Color arcSport          = Color(0xFF9E653F); // 160–250: muted amber
  static const Color arcDanger         = Color(0xFF8F3232); // 250–300: muted dark red

  // ─── Tick Marks ──────────────────────────────────────────────────────────────
  static const Color tickMajor         = Color(0xFFCDCDD2); // crisp pale silver
  static const Color tickMinor         = Color(0xFF3E3E46); // dark slate grey
  static const Color tickSport         = Color(0xFF9E653F); 
  static const Color tickDanger        = Color(0xFF8F3232); 

  // ─── Needle ──────────────────────────────────────────────────────────────────
  // Sleek, mechanical, less neon.
  static const Color needleBase        = Color(0xFFB5B5BE); // metallic base
  static const Color needleTip         = Color(0xFFD64428); // distinct but non-glowing red-orange
  static const Color needleShaft       = Color(0xFF8A8A94); // mid shaft
  static const Color needleKnobCenter  = Color(0xFF0A0A0C);
  static const Color needleKnobRing    = Color(0xFF24242A);
  static const Color needleTail        = Color(0xFF1C1C20);

  // ─── Center Display ──────────────────────────────────────────────────────────
  static const Color speedDigit        = Color(0xFFE8E8EC);
  static const Color speedUnit         = Color(0xFF5E5E68);
  static const Color driveMode         = Color(0xFF8F3232);
  static const Color driveModeComfort  = Color(0xFF4F6B8F);
  static const Color driveModeSport    = Color(0xFF9E653F);

  // ─── UI Controls ─────────────────────────────────────────────────────────────
  static const Color btnActiveBorder   = Color(0xFF4A4A52);
  static const Color btnInactiveBorder = Color(0xFF16161A);
  static const Color btnInactiveFill   = Color(0xFF0C0C0F);

  // ─── Status & Indicators ─────────────────────────────────────────────────────
  static const Color statusActive      = Color(0xFF5E6D5E); // muted sage green
  static const Color statusIdle        = Color(0xFF24242A);

  // ─── Ambient Glow ────────────────────────────────────────────────────────────
  // Extremely subtle. Just enough to separate layers.
  static const Color glowRed           = Color(0x118F3232);
  static const Color glowAmber         = Color(0x119E653F);
  static const Color glowBlue          = Color(0x114F6B8F);
}
