// trips_screen.dart — Clean list.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/trip_card.dart';
import '../../services/trip_storage_service.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'RECENT SESSIONS',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: const Color(0xFF5A5A64),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListenableBuilder(
              listenable: TripStorageService(),
              builder: (context, _) {
                final trips = TripStorageService().trips;
                if (trips.isEmpty) {
                  return Center(
                    child: Text(
                      'NO SESSIONS RECORDED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5A5A64),
                        letterSpacing: 2.0,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return TripCard(trip: trips[index], delayMs: 0);
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
