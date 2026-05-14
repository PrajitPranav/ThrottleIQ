// analytics_screen.dart — Placeholder analytics screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    icon: Icons.bar_chart_rounded,
    title: 'ANALYTICS',
    subtitle: 'Performance insights coming soon',
  );
}

// garage_screen.dart equivalent placeholder
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    icon: Icons.garage_rounded,
    title: 'GARAGE',
    subtitle: 'Vehicle management coming soon',
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    icon: Icons.person_outline_rounded,
    title: 'PROFILE',
    subtitle: 'Driver profile coming soon',
  );
}

// Shared placeholder layout — minimal and premium
class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;

  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF1E1E28))
              .animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 4.0,
              color: const Color(0xFF2A2A36),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.exo2(
              fontSize: 10,
              letterSpacing: 1.5,
              color: const Color(0xFF22222C),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
