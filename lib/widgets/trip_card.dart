// trip_card.dart — Premium glassmorphism trip history card.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip_model.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final int       index;

  const TripCard({super.key, required this.trip, required this.index});

  // Drive score color
  Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF26A65B);
    if (score >= 75) return const Color(0xFFE08020);
    return const Color(0xFFCC1800);
  }

  // Mode accent color
  Color _modeColor(String mode) {
    switch (mode) {
      case 'SPORT+': return const Color(0xFFCC1800);
      case 'SPORT':  return const Color(0xFFE08020);
      case 'ECO':    return const Color(0xFF26A65B);
      default:       return const Color(0xFF4A9ECC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color modeColor = _modeColor(trip.mode);
    final Color scoreColor = _scoreColor(trip.driveScore);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D12).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: modeColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: modeColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      trip.mode,
                      style: GoogleFonts.exo2(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: modeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                trip.dateTime,
                style: GoogleFonts.exo2(
                  fontSize: 8,
                  letterSpacing: 1.0,
                  color: const Color(0xFF3A3A4A),
                ),
              ),
              const SizedBox(height: 14),

              // Stats row
              Row(
                children: [
                  _stat('TOP SPEED', '${trip.topSpeedKmh.round()} KM/H'),
                  _stat('DISTANCE',  '${trip.distanceKm.toStringAsFixed(1)} KM'),
                  _stat('DURATION',  trip.duration),
                ],
              ),

              const SizedBox(height: 14),

              // Drive score bar
              Row(
                children: [
                  Text(
                    'DRIVE SCORE',
                    style: GoogleFonts.exo2(
                      fontSize: 7,
                      letterSpacing: 2,
                      color: const Color(0xFF3A3A4A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trip.driveScore}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ 100',
                    style: GoogleFonts.exo2(
                      fontSize: 8,
                      color: const Color(0xFF3A3A4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Score progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: trip.driveScore / 100,
                  backgroundColor: const Color(0xFF1A1A22),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 7,
              letterSpacing: 1.5,
              color: const Color(0xFF3A3A4A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
