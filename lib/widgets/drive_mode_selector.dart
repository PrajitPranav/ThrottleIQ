// drive_mode_selector.dart — Animated horizontal drive mode picker.
// Tapping a mode chip smoothly transitions accent colors across the whole app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drive_mode.dart';

class DriveModeSelector extends StatelessWidget {
  final DriveMode            selected;
  final ValueChanged<DriveMode> onChanged;

  const DriveModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DRIVE MODE',
            style: GoogleFonts.exo2(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: const Color(0xFF3A3A48),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: DriveMode.values.map((mode) {
              final bool isActive = mode == selected;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: mode != DriveMode.sportPlus ? 8 : 0,
                  ),
                  child: _ModeChip(
                    mode:     mode,
                    isActive: isActive,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onChanged(mode);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final DriveMode mode;
  final bool      isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? mode.accent.withValues(alpha: 0.14)
              : const Color(0xFF0D0D12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? mode.accent.withValues(alpha: 0.55)
                : const Color(0xFF1C1C24),
            width: isActive ? 1.2 : 0.8,
          ),
          boxShadow: isActive
              ? [BoxShadow(
                  color: mode.accent.withValues(alpha: 0.20),
                  blurRadius: 18,
                  spreadRadius: 0,
                )]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              style: GoogleFonts.exo2(
                fontSize: isActive ? 10 : 9,
                fontWeight: FontWeight.w800,
                letterSpacing: isActive ? 2.0 : 1.5,
                color: isActive ? mode.accent : const Color(0xFF3A3A48),
              ),
              child: Text(mode.label, textAlign: TextAlign.center),
            ),

            // Active indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(top: 6),
              height: 2,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: mode.accent,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [BoxShadow(
                  color: mode.accent.withValues(alpha: 0.8),
                  blurRadius: 4,
                )],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
