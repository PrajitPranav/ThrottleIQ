// vehicle_status_panel.dart — Small premium status indicator row.
// Shows GPS, Track Mode, System, Stability, Connection placeholders.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleStatusPanel extends StatelessWidget {
  const VehicleStatusPanel({super.key});

  static const _statuses = [
    (Icons.gps_fixed_rounded,        'GPS READY',         true,  Color(0xFF26A65B)),
    (Icons.track_changes_rounded,     'TRACK MODE',        true,  Color(0xFFE08020)),
    (Icons.memory_rounded,            'SYSTEM ONLINE',     true,  Color(0xFF4A9ECC)),
    (Icons.shield_outlined,           'STABILITY ACTIVE',  true,  Color(0xFF4A9ECC)),
    (Icons.signal_wifi_4_bar_rounded, 'CONNECTION',        true,  Color(0xFF26A65B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VEHICLE STATUS',
            style: GoogleFonts.exo2(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: const Color(0xFF3A3A48),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_statuses.length, (i) {
              final s = _statuses[i];
              return _StatusChip(
                icon:    s.$1,
                label:   s.$2,
                active:  s.$3,
                color:   s.$4,
              ).animate(delay: (i * 80).ms).fadeIn(duration: 350.ms);
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  final Color    color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.09) : const Color(0xFF0F0F14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? color.withValues(alpha: 0.30) : const Color(0xFF1A1A22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing indicator dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : const Color(0xFF333340),
              boxShadow: active
                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]
                  : [],
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 10, color: active ? color : const Color(0xFF333340)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: active ? color.withValues(alpha: 0.85) : const Color(0xFF333340),
            ),
          ),
        ],
      ),
    );
  }
}
