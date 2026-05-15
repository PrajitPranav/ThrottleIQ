// bottom_nav_bar.dart — Simple, premium floating navigation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drive_mode.dart';

class BottomNavBar extends StatelessWidget {
  final int                     selectedIndex;
  final ValueChanged<int>       onTap;
  final DriveMode               driveMode;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.driveMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E1E24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(idx: 0, label: 'DASH',  icon: Icons.speed_rounded,      sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
          _NavItem(idx: 1, label: 'MAP',   icon: Icons.map_rounded,        sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
          _NavItem(idx: 2, label: 'TRIPS', icon: Icons.route_rounded,      sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
          _NavItem(idx: 3, label: 'DATA',  icon: Icons.analytics_outlined, sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
          _NavItem(idx: 4, label: 'GARAGE',icon: Icons.directions_car_outlined, sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
          _NavItem(idx: 5, label: 'PROFILE',icon: Icons.person_outline,  sel: selectedIndex, acc: driveMode.accent, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int      idx;
  final String   label;
  final IconData icon;
  final int      sel;
  final Color    acc;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.idx,
    required this.label,
    required this.icon,
    required this.sel,
    required this.acc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = sel == idx;
    final Color iconColor = active ? Colors.white : const Color(0xFF5A5A64);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(idx);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.inter(
                fontSize: 7,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.5,
                color: active ? acc : const Color(0xFF5A5A64),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
