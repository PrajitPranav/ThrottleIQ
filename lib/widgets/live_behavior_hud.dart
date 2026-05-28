// live_behavior_hud.dart — Compact live driving behavior indicator strip.
//
// Displays real-time driving events from GpsService analytics sub-services:
//   • Acceleration state (smooth / aggressive)
//   • Braking state (active / harsh)
//   • Turn counts (left / right / sharp)
//
// Only shows meaningful content when telemetry is active.
// Uses color-coded indicators with animated transitions for premium feel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gps_service.dart';

class LiveBehaviorHud extends StatelessWidget {
  const LiveBehaviorHud({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GpsService(),
      builder: (context, _) {
        final gps    = GpsService();
        final active = gps.isActive;

        return AnimatedOpacity(
          opacity: active ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: active
              ? _buildHud(gps)
              : const SizedBox(height: 56),
        );
      },
    );
  }

  Widget _buildHud(GpsService gps) {
    // ── Acceleration state ──
    final bool isAggressive = gps.isAccelerating &&
        gps.currentAccelMs2.abs() >= 3.5;
    final bool isSmooth = gps.isAccelerating &&
        gps.currentAccelMs2.abs() < 3.5;
    final bool isBraking = gps.isBraking;
    final bool isHarshBrake = isBraking &&
        gps.currentAccelMs2 <= -3.0;

    final Color accelColor = isAggressive
        ? const Color(0xFFE85C3A)   // aggressive: amber-red
        : isSmooth
            ? const Color(0xFF5A7D65) // smooth: sage green
            : const Color(0xFF3A3A44); // idle: dim

    final Color brakeColor = isHarshBrake
        ? const Color(0xFF8F3232)   // harsh: deep red
        : isBraking
            ? const Color(0xFF9E653F) // soft: amber
            : const Color(0xFF3A3A44); // idle: dim

    final int totalTurns = gps.leftTurnCount + gps.rightTurnCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Acceleration indicator ──
          Expanded(
            child: _BehaviorTile(
              icon: Icons.arrow_upward_rounded,
              label: 'ACCEL',
              value: isAggressive
                  ? 'AGGRESSIVE'
                  : isSmooth
                      ? 'SMOOTH'
                      : '${gps.aggressiveAccelCount + gps.smoothAccelCount} EVENTS',
              color: accelColor,
              count: gps.aggressiveAccelCount,
              countLabel: 'HARD',
            ),
          ),
          const SizedBox(width: 10),

          // ── Braking indicator ──
          Expanded(
            child: _BehaviorTile(
              icon: Icons.arrow_downward_rounded,
              label: 'BRAKE',
              value: isHarshBrake
                  ? 'HARSH'
                  : isBraking
                      ? 'BRAKING'
                      : '${gps.harshBrakingCount} HARSH',
              color: brakeColor,
              count: gps.harshBrakingCount,
              countLabel: 'HARD',
            ),
          ),
          const SizedBox(width: 10),

          // ── Turn indicator ──
          Expanded(
            child: _BehaviorTile(
              icon: Icons.sync_rounded,
              label: 'TURNS',
              value: '$totalTurns TOTAL',
              color: const Color(0xFF4F6B8F),
              count: gps.sharpTurnCount,
              countLabel: 'SHARP',
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  final int      count;
  final String   countLabel;

  const _BehaviorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.count,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (count > 0) ...[
            const SizedBox(height: 2),
            Text(
              '$count $countLabel',
              style: GoogleFonts.inter(
                fontSize: 7,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
