// trip_timer_widget.dart — Premium live trip timer display.
//
// Reads TripTimerService and renders a compact HH:MM:SS / MM:SS display.
// Shows a pulsing active dot when the timer is running.
// Fades out when trip is not active.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/trip_timer_service.dart';

class TripTimerWidget extends StatefulWidget {
  const TripTimerWidget({super.key});

  @override
  State<TripTimerWidget> createState() => _TripTimerWidgetState();
}

class _TripTimerWidgetState extends State<TripTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    TripTimerService().addListener(_onTimerUpdate);
  }

  void _onTimerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    TripTimerService().removeListener(_onTimerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer   = TripTimerService();
    final running = timer.isRunning;

    return AnimatedOpacity(
      opacity: running ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF101014),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: running
                ? const Color(0xFF5A7D65).withValues(alpha: 0.5)
                : const Color(0xFF1E1E22),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing indicator dot
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Opacity(
                opacity: running ? _pulseAnim.value : 0.3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: running
                        ? const Color(0xFF5A7D65)
                        : const Color(0xFF4A4A52),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TRIP DURATION',
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: const Color(0xFF5A5A64),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  running ? timer.formattedTime : '--:--',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.0,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
