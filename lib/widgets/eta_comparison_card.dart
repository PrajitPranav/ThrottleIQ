import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EtaComparisonCard extends StatelessWidget {
  final int actualMinutes;
  final int expectedMinutes;
  final DateTime startTime;
  final DateTime endTime;

  const EtaComparisonCard({
    super.key, 
    required this.actualMinutes, 
    required this.expectedMinutes,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final diff = expectedMinutes - actualMinutes;
    final bool isFaster = diff > 0;
    final String diffText = diff.abs() > 0 
        ? "${_formatDiff(diff.abs())} ${isFaster ? 'Faster' : 'Slower'}"
        : "On Time";
    
    final Color accentColor = isFaster ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);
    final timeFormat = DateFormat('HH:mm');

    // Calculate Estimated Arrival Time
    final estimatedArrival = startTime.add(Duration(minutes: expectedMinutes));

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
                'TRAVEL PERFORMANCE',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: const Color(0xFF5A5A64),
                ),
              ),
              Icon(isFaster ? Icons.bolt_rounded : Icons.timer_outlined, size: 14, color: accentColor),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol('EST. ARRIVAL', timeFormat.format(estimatedArrival), _formatDiff(expectedMinutes)),
              _timeCol('ACTUAL ARRIVAL', timeFormat.format(endTime), _formatDiff(actualMinutes)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isFaster ? '↑' : '↓',
                    style: GoogleFonts.inter(fontSize: 18, color: accentColor, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    diffText.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 0.5,
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

  Widget _timeCol(String label, String time, String duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF5A5A64), fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: GoogleFonts.inter(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300, letterSpacing: -0.5),
        ),
        Text(
          duration,
          style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF7A7A85), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDiff(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
