// telemetry_card.dart — Premium glassmorphism telemetry info card.
// Used in a 2-column grid on the dashboard.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TelemetryCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String   unit;
  final Color    accentColor;

  const TelemetryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.accentColor = const Color(0xFF4A9ECC),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F14).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon + label row
              Row(
                children: [
                  Icon(icon, size: 13, color: accentColor.withValues(alpha: 0.75)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.exo2(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: const Color(0xFF555565),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Value
              Text(
                value,
                style: GoogleFonts.rajdhani(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.0,
                ),
              ),

              // Unit
              Text(
                unit,
                style: GoogleFonts.exo2(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: accentColor.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
