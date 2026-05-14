// animated_bg.dart — Full-screen breathing ambient background.
// A slow AnimationController drives a sin-wave opacity pulse on two
// RadialGradient overlays whose color tracks the active DriveMode.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drive_mode.dart';

class AnimatedDashboardBg extends StatefulWidget {
  final DriveMode driveMode;
  final Widget child;

  const AnimatedDashboardBg({
    super.key,
    required this.driveMode,
    required this.child,
  });

  @override
  State<AnimatedDashboardBg> createState() => _AnimatedDashboardBgState();
}

class _AnimatedDashboardBgState extends State<AnimatedDashboardBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        // Soft sine curve → 0.0 to 1.0 breathing
        final double t = (math.sin(_breath.value * math.pi));
        final Color modeColor = widget.driveMode.bgOverlay;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Base: deep matte black
            const ColoredBox(color: Color(0xFF050507)),

            // Top ambient glow — drive mode color, breathes slowly
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.5),
                    radius: 0.9,
                    colors: [
                      Color.lerp(modeColor, modeColor.withValues(alpha: 0), 0.2 + t * 0.3)!,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-right secondary glow — very subtle graphite
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1A1A20).withValues(alpha: 0.5 + t * 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Foreground content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
