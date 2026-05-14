// home_screen.dart — ThrottleIQ navigation shell.
//
// Holds all top-level state:
//   • _driveMode   → propagated to dashboard, HUD strip, bottom nav, animated bg
//   • _tabIndex    → which screen is showing
//
// Layout:
//   AnimatedDashboardBg (full-screen, responds to drive mode)
//     SafeArea
//       Column
//         HudStrip (thin top bar)
//         Expanded → IndexedStack (Dashboard / Trips / Analytics / Garage / Profile)
//         BottomNavBar (floating)

import 'package:flutter/material.dart';
import '../../models/drive_mode.dart';
import '../../widgets/animated_bg.dart';
import '../../widgets/hud_strip.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/trips/trips_screen.dart';
import '../../features/analytics/analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DriveMode _driveMode = DriveMode.sport;
  int       _tabIndex  = 0;

  void _onDriveModeChanged(DriveMode mode) {
    setState(() => _driveMode = mode);
  }

  void _onTabChanged(int index) {
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: AnimatedDashboardBg(
        driveMode: _driveMode,
        child: SafeArea(
          child: Column(
            children: [
              // Thin HUD strip at top
              HudStrip(driveMode: _driveMode),

              // Screen content
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    // 0 — Dashboard
                    DashboardScreen(
                      driveMode:          _driveMode,
                      onDriveModeChanged: _onDriveModeChanged,
                    ),

                    // 1 — Trips
                    const TripsScreen(),

                    // 2 — Analytics
                    const AnalyticsScreen(),

                    // 3 — Garage
                    const GarageScreen(),

                    // 4 — Profile
                    const ProfileScreen(),
                  ],
                ),
              ),

              // Floating bottom navigation
              BottomNavBar(
                selectedIndex: _tabIndex,
                driveMode:     _driveMode,
                onTap:         _onTabChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
