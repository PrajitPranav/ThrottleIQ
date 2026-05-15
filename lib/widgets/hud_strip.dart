// hud_strip.dart — Clean, minimal top HUD bar.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drive_mode.dart';
import '../core/app_colors.dart';

class HudStrip extends StatelessWidget {
  final DriveMode driveMode;

  const HudStrip({super.key, required this.driveMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.chromeOuter, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _item(Icons.thermostat_outlined, '24°C'),
          _divider(),
          _item(Icons.explore_outlined, 'NNW'),
          _divider(),

          // Minimal Mode Chip
          Text(
            driveMode.label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: driveMode.accent,
            ),
          ),

          const Spacer(),

          _item(Icons.wifi, 'CONNECTED', color: const Color(0xFF5A7D65)),
          _divider(),
          _timeItem(),
          _divider(),
          _item(Icons.battery_charging_full_rounded, '87%'),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, {Color? color}) {
    final Color c = color ?? const Color(0xFF7A7A85);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: c),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: c,
          ),
        ),
      ],
    );
  }

  Widget _timeItem() {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return _item(Icons.access_time_rounded, '$h:$m');
  }

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    width: 1,
    height: 12,
    color: const Color(0xFF2C2C32),
  );
}
