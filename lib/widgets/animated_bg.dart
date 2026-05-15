// animated_bg.dart — Subtle, minimalist dark background.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drive_mode.dart';
import '../core/app_colors.dart';

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
    // Very slow, subtle brightness pulse to feel alive but not distracting
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
        final double t = (math.sin(_breath.value * math.pi));
        final Color overlay = widget.driveMode.bgOverlay;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Deep matte base
            const ColoredBox(color: AppColors.backgroundDeep),

            // Top subtle gradient
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.6),
                    radius: 1.0,
                    colors: [
                      overlay.withValues(alpha: overlay.a * (0.8 + t * 0.2)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
