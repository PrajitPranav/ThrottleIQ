// bottom_nav_bar.dart — Custom floating premium navigation bar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drive_mode.dart';

class BottomNavBar extends StatelessWidget {
  final int      selectedIndex;
  final DriveMode driveMode;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.driveMode,
    required this.onTap,
  });

  static const _tabs = [
    (Icons.speed_rounded,         'DASH'),
    (Icons.route_rounded,         'TRIPS'),
    (Icons.bar_chart_rounded,     'ANALYTICS'),
    (Icons.garage_rounded,        'GARAGE'),
    (Icons.person_outline_rounded,'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFF09090D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: driveMode.accent.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: driveMode.accent.withValues(alpha: 0.06),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final bool active = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: active
                            ? driveMode.accent.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _tabs[i].$1,
                        size: 20,
                        color: active
                            ? driveMode.accent
                            : const Color(0xFF333340),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.exo2(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: active
                            ? driveMode.accent
                            : const Color(0xFF2A2A36),
                      ),
                      child: Text(_tabs[i].$2),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
