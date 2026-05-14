// dashboard_screen.dart — Main telemetry dashboard.
// Contains: speedometer (existing), telemetry cards, drive mode selector,
// vehicle status panel. Drive mode state comes from home_screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/drive_mode.dart';
import '../../widgets/speedometer_widget.dart';
import '../../widgets/telemetry_card.dart';
import '../../widgets/drive_mode_selector.dart';
import '../../widgets/vehicle_status_panel.dart';

class DashboardScreen extends StatelessWidget {
  final DriveMode            driveMode;
  final ValueChanged<DriveMode> onDriveModeChanged;

  const DashboardScreen({
    super.key,
    required this.driveMode,
    required this.onDriveModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Existing speedometer — completely untouched
          const SpeedometerWidget(),

          const SizedBox(height: 4),

          // ── Telemetry Cards Grid ──────────────────────────────────────────
          _sectionLabel('TELEMETRY'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TelemetryCard(
                  icon: Icons.speed_rounded,
                  label: 'AVG SPEED',
                  value: '78',
                  unit: 'KM/H',
                  accentColor: const Color(0xFF4A9ECC),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                TelemetryCard(
                  icon: Icons.north_rounded,
                  label: 'TOP SPEED',
                  value: '184',
                  unit: 'KM/H',
                  accentColor: const Color(0xFFCC1800),
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),
                TelemetryCard(
                  icon: Icons.route_rounded,
                  label: 'DISTANCE',
                  value: '26.4',
                  unit: 'KM',
                  accentColor: const Color(0xFF26A65B),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                TelemetryCard(
                  icon: Icons.timer_outlined,
                  label: 'TRIP TIME',
                  value: '42:12',
                  unit: 'MM:SS',
                  accentColor: const Color(0xFFE08020),
                ).animate(delay: 260.ms).fadeIn(duration: 400.ms),
                TelemetryCard(
                  icon: Icons.compass_calibration_outlined,
                  label: 'G-FORCE',
                  value: '0.82',
                  unit: 'G',
                  accentColor: const Color(0xFFCC1800),
                ).animate(delay: 320.ms).fadeIn(duration: 400.ms),
                TelemetryCard(
                  icon: Icons.verified_outlined,
                  label: 'DRIVE STATUS',
                  value: 'READY',
                  unit: 'TRACK ENABLED',
                  accentColor: const Color(0xFF26A65B),
                ).animate(delay: 380.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Drive Mode Selector ───────────────────────────────────────────
          _sectionLabel('DRIVE MODE'),
          const SizedBox(height: 10),
          DriveModeSelector(
            selected:  driveMode,
            onChanged: onDriveModeChanged,
          ),

          const SizedBox(height: 24),

          // ── Vehicle Status ────────────────────────────────────────────────
          const VehicleStatusPanel(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.exo2(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: const Color(0xFF3A3A4A),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: Color(0xFF1A1A22), height: 1)),
        ],
      ),
    );
  }
}
