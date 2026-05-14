// trips_screen.dart — Premium trip history screen with placeholder data.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip_model.dart';
import '../../widgets/trip_card.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRIP HISTORY',
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${TripModel.placeholders.length} SESSIONS RECORDED',
                  style: GoogleFonts.exo2(
                    fontSize: 9,
                    letterSpacing: 2.0,
                    color: const Color(0xFF3A3A4A),
                  ),
                ),

                const SizedBox(height: 16),

                // Summary stat row
                Row(
                  children: [
                    _summaryChip('TOTAL DIST', '218.6 KM'),
                    const SizedBox(width: 12),
                    _summaryChip('BEST SCORE', '98 / 100'),
                    const SizedBox(width: 12),
                    _summaryChip('PEAK SPEED', '272 KM/H'),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Trip cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => TripCard(
                trip:  TripModel.placeholders[i],
                index: i,
              ),
              childCount: TripModel.placeholders.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _summaryChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1A1A22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: GoogleFonts.exo2(
                fontSize: 7, letterSpacing: 1.5,
                color: const Color(0xFF3A3A4A),
              )),
            const SizedBox(height: 3),
            Text(value,
              style: GoogleFonts.rajdhani(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              )),
          ],
        ),
      ),
    );
  }
}
