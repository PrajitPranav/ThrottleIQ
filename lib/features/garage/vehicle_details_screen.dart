import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/vehicle.dart';
import '../../services/garage_service.dart';
import '../../services/settings_service.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final garage = GarageService();
    final settings = SettingsService();
    final stats = garage.getVehicleStats(vehicle.id);

    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'VEHICLE OVERVIEW',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _vehicleHeader(),
            const SizedBox(height: 48),
            _lifetimeStats(stats, settings),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _vehicleHeader() {
    return Column(
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF101014),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1E1E22), width: 2),
          ),
          child: const Center(child: Icon(Icons.directions_car_rounded, size: 64, color: Color(0xFF5A5A64))),
        ),
        const SizedBox(height: 24),
        Text(
          vehicle.make.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 3.0),
        ),
        const SizedBox(height: 8),
        Text(
          vehicle.model,
          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: -1.0),
        ),
      ],
    );
  }

  Widget _lifetimeStats(Map<String, dynamic> stats, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIFETIME PERFORMANCE',
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: const Color(0xFF5A5A64)),
          ),
          const SizedBox(height: 24),
          _statRow('TOTAL DISTANCE', settings.formatDistance(stats['totalDistanceKm']), settings.distanceUnit),
          _divider(),
          _statRow('TRIPS COMPLETED', stats['totalTrips'].toString(), 'SESSIONS'),
          _divider(),
          _statRow('AVERAGE SPEED', settings.formatSpeed(stats['avgSpeedKmh']), settings.speedUnit),
          _divider(),
          _statRow('TOP SPEED OVERALL', settings.formatSpeed(stats['topSpeedKmh']), settings.speedUnit),
          _divider(),
          _statRow('DRIVING DURATION', _formatDuration(stats['totalDurationMinutes']), ''),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF8A8A94))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFF16161A), height: 1);

  String _formatDuration(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) return '${h}H ${m}M';
    return '${m}M';
  }
}
