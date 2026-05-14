// hud_strip.dart — Thin futuristic HUD strip at the top of the dashboard.
// Shows: temperature, compass, active drive mode, connection, time, battery.

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
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF08080C),
        border: Border(
          bottom: BorderSide(
            color: driveMode.accent.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _item(Icons.thermostat_outlined, '24°C'),
          _divider(),
          _item(Icons.explore_outlined, 'NNW'),
          _divider(),

          // Drive mode chip — glows in mode accent
          _modeChip(),

          const Spacer(),

          _item(Icons.wifi, 'CONNECTED', color: const Color(0xFF26A65B)),
          _divider(),
          _timeItem(),
          _divider(),
          _item(Icons.battery_charging_full_rounded, '87%'),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, {Color? color}) {
    final Color c = color ?? AppColors.speedUnit;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: c,
          ),
        ),
      ],
    );
  }

  Widget _modeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: driveMode.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: driveMode.accent.withValues(alpha: 0.35), width: 0.8),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: GoogleFonts.exo2(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: driveMode.accent,
        ),
        child: Text(driveMode.label),
      ),
    );
  }

  Widget _timeItem() {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return _item(Icons.access_time_rounded, '$h:$m');
  }

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    width: 1,
    height: 14,
    color: const Color(0xFF1E1E26),
  );
}
