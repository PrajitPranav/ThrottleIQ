import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EtaComparisonCard extends StatelessWidget {
  final int actualMinutes;
  final int? expectedMinutes;

  const EtaComparisonCard({super.key, required this.actualMinutes, this.expectedMinutes});

  @override
  Widget build(BuildContext context) {
    if (expectedMinutes == null) return const SizedBox.shrink();

    final diff = expectedMinutes! - actualMinutes;
    final bool isFaster = diff > 0;
    final String diffText = diff.abs() > 0 
        ? "${_formatTime(diff.abs())} ${isFaster ? 'Faster' : 'Late'}"
        : "On Time";
    
    final Color accentColor = isFaster ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRAVEL TIME EFFICIENCY',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: const Color(0xFF5A5A64),
                ),
              ),
              Icon(Icons.timer_outlined, size: 14, color: accentColor.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _timeCol('EXPECTED', _formatTime(expectedMinutes!)),
              const SizedBox(width: 32),
              _timeCol('ACTUAL', _formatTime(actualMinutes)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    diffText.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeCol(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF5A5A64), fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatTime(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
