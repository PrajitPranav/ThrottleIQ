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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DriveMode _driveMode = DriveMode.sport;
  int       _tabIndex  = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: AnimatedDashboardBg(
        driveMode: _driveMode,
        child: SafeArea(
          child: Column(children: [
            HudStrip(driveMode: _driveMode),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  DashboardScreen(
                    driveMode: _driveMode,
                    onDriveModeChanged: (m) => setState(() => _driveMode = m),
                  ),
                  MapScreen(driveMode: _driveMode),
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
          driveMode:     _driveMode,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
      ),
    );
  }
}
