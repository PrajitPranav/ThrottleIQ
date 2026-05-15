// dashboard_screen.dart — Minimalist layout.

import 'package:flutter/material.dart';
import '../../models/drive_mode.dart';
import '../../widgets/speedometer_widget.dart';
import '../../widgets/telemetry_card.dart';
import '../../services/gps_service.dart';
import '../../widgets/drive_mode_selector.dart';
import '../../widgets/vehicle_status_panel.dart';
import '../../services/settings_service.dart';

class DashboardScreen extends StatelessWidget {
  final DriveMode driveMode;
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
          const SizedBox(height: 24),
          SpeedometerWidget(driveMode: driveMode),
          
          DriveModeSelector(
            selected: driveMode,
            onChanged: onDriveModeChanged,
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListenableBuilder(
              listenable: Listenable.merge([GpsService(), SettingsService()]),
              builder: (context, _) {
                final gps = GpsService();
                final settings = SettingsService();
                
                // Calculate average speed
                final double distanceKm = gps.totalDistanceKm;
                final double minutes = gps.tripDurationMinutes.toDouble();
                final double hours = minutes / 60.0;
                final double avgSpeedKmph = hours > 0 ? (distanceKm / hours) : 0.0;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TelemetryCard(
                          label: 'AVG SPEED', 
                          value: settings.formatSpeed(avgSpeedKmph), 
                          unit: settings.speedUnit
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: TelemetryCard(
                          label: 'TOP SPEED', 
                          value: settings.formatSpeed(gps.topSpeed), 
                          unit: settings.speedUnit
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TelemetryCard(
                          label: 'DISTANCE', 
                          value: settings.formatDistance(gps.totalDistanceKm), 
                          unit: settings.distanceUnit
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: TelemetryCard(
                          label: 'TRIP TIME', 
                          value: gps.tripDurationMinutes.toString(), 
                          unit: 'MIN'
                        )),
                      ],
                    ),
                  ],
                );
              }
            ),
          ),
          
          const SizedBox(height: 32),
          const VehicleStatusPanel(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
