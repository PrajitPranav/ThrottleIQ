// home_screen.dart — ThrottleIQ navigation shell.

import 'package:flutter/material.dart';
import '../../models/drive_mode.dart';
import '../../widgets/animated_bg.dart';
import '../../widgets/hud_strip.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/trips/trips_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/garage/garage_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/map/map_screen.dart';

import '../../services/drive_mode_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DriveModeService(),
      builder: (context, _) {
        final driveModeService = DriveModeService();
        final driveMode = driveModeService.currentMode;

        return Scaffold(
          backgroundColor: const Color(0xFF050507),
          body: AnimatedDashboardBg(
            driveMode: driveMode,
            child: SafeArea(
              child: Column(children: [
                HudStrip(driveMode: driveMode),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      DashboardScreen(
                        driveMode: driveMode,
                        onDriveModeChanged: (m) => driveModeService.setMode(m),
                      ),
                      MapScreen(driveMode: driveMode),
                      const TripsScreen(),
                      const AnalyticsScreen(),
                      const GarageScreen(),
                      const ProfileScreen(),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: BottomNavBar(
              selectedIndex: _tabIndex,
              driveMode:     driveMode,
              onTap: (i) => setState(() => _tabIndex = i),
            ),
          ),
        );
      }
    );
  }
}
