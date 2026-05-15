// trip_card.dart — Clean trip history card.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import '../../models/trip.dart';
import '../features/trips/trip_details_screen.dart';
import '../services/settings_service.dart';
import '../services/trip_storage_service.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final int delayMs;

  const TripCard({super.key, required this.trip, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy  •  HH:mm');
    
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => TripDetailsScreen(trip: trip),
            ));
          },
          onLongPress: () => _confirmDelete(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E22)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(trip.startTime),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: const Color(0xFF7A7A85),
                      ),
                    ),
                    Row(
                      children: [
                        if (trip.expectedDurationMinutes != null && trip.expectedDurationMinutes != trip.durationMinutes) ...[
                          Builder(
                            builder: (context) {
                              final diff = trip.expectedDurationMinutes! - trip.durationMinutes;
                              final bool isFaster = diff > 0;
                              final Color accentColor = isFaster ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);
                              final IconData icon = isFaster ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
                              final String text = isFaster ? 'Faster' : 'Slower';
                              
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icon, size: 10, color: accentColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      text,
                                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: accentColor),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Score: ${trip.tripScore}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric('Distance', settings.formatDistance(trip.distanceKm), settings.distanceUnit),
                    _metric('Duration', '${trip.durationMinutes}m', ''),
                    _metric('Avg Spd', settings.formatSpeed(trip.averageSpeedKmh), settings.speedUnit),
                    _metric('Top Spd', settings.formatSpeed(trip.topSpeedKmh), settings.speedUnit),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _metric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            color: const Color(0xFF5A5A64),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: const Color(0xFF7A7A85),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('DELETE TRIP', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text('Remove this session from history?', 
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A94))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              TripStorageService().deleteTrip(trip.id);
              Navigator.pop(ctx);
            },
            child: const Text('DELETE', style: TextStyle(color: Color(0xFF8F3232))),
          ),
        ],
      ),
    );
  }
}
