// home_screen.dart — ThrottleIQ main dashboard screen.
//
// Layout:
//   • Custom premium header (replaces standard AppBar)
//   • Full-bleed dark background with subtle top gradient
//   • SpeedometerWidget as the immersive centerpiece

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/speedometer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,

      body: Stack(
        children: [
          // Subtle top radial glow — creates an immersive cockpit atmosphere
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    Color(0x18CC2200), // subtle deep red at top
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Expanded(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SpeedometerWidget(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PREMIUM HEADER ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Left: App brand
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name — tight tracking, bold
              const Text(
                'THROTTLE IQ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              // Subtitle
              Text(
                'TELEMETRY DASHBOARD v1.0',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.5,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: Red accent mark (decorative — like M badge area)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.btnActiveBorder.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.btnActiveBorder,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
