// drive_mode_selector.dart — Clean, flat drive mode selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: const Color(0xFF5A5A64),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: DriveMode.values.map((mode) {
              final bool isActive = mode == selected;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: mode != DriveMode.sportPlus ? 6 : 0,
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? mode.accent.withValues(alpha: 0.1) : const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? mode.accent.withValues(alpha: 0.5) : const Color(0xFF1C1C20),
            width: 1.0,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 1.5,
            color: isActive ? mode.accent : const Color(0xFF5A5A64),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(mode.label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
