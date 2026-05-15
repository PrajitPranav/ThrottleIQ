// needle_painter.dart — Precision mechanical needle.

import 'package:flutter/material.dart';
import '../models/drive_mode.dart';
import 'gauge_painter.dart';

class NeedlePainter extends CustomPainter {
  final double speed;
  final DriveMode driveMode;
  final bool useMetric;

  const NeedlePainter({required this.speed, required this.driveMode, required this.useMetric});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    final double angle = GaugePainter.speedToAngle(speed, useMetric);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    _drawNeedleShadow(canvas, radius);
    _drawSharpNeedle(canvas, radius);
    _drawMetallicHub(canvas, radius);

    canvas.restore();
  }

  void _drawNeedleShadow(Canvas canvas, double radius) {
    final double length = radius * 0.86;
    final double baseWidth = radius * 0.03;
    final double tailLength = radius * 0.18;

    final Path path = Path()
      ..moveTo(0, -baseWidth / 2)
      ..lineTo(length, 0)
      ..lineTo(0, baseWidth / 2)
      ..lineTo(-tailLength, baseWidth * 0.3)
      ..lineTo(-tailLength, -baseWidth * 0.3)
      ..close();

    // Tight, realistic drop shadow indicating physical depth
    canvas.drawPath(
      path.shift(const Offset(-1.5, 3.0)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawSharpNeedle(Canvas canvas, double radius) {
    final double length = radius * 0.86; // Extends slightly into the track
    final double baseWidth = radius * 0.03;
    final double tailLength = radius * 0.18;

    final Path path = Path()
      ..moveTo(0, -baseWidth / 2)
      ..lineTo(length, 0) // Pinpoint tip
      ..lineTo(0, baseWidth / 2)
      ..lineTo(-tailLength, baseWidth * 0.3)
      ..lineTo(-tailLength, -baseWidth * 0.3)
      ..close();

    // Blade gradient based on drive mode
    List<Color> gradientColors;
    if (driveMode == DriveMode.eco) {
      gradientColors = [const Color(0xFF4A6B53), const Color(0xFF86B896)];
    } else if (driveMode == DriveMode.comfort) {
      gradientColors = [const Color(0xFF5A5A64), const Color(0xFFB5B5BE)];
    } else if (driveMode == DriveMode.sport) {
      gradientColors = [const Color(0xFF9E653F), const Color(0xFFD49A6A)];
    } else {
      gradientColors = [const Color(0xFF8F3232), const Color(0xFFD64428)]; // Sport+
    }

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ).createShader(Rect.fromLTRB(-tailLength, -baseWidth, length, baseWidth)),
    );

    // Sharp specular highlight edge (simulates gloss/bevel)
    final Path highlight = Path()
      ..moveTo(-tailLength, -baseWidth * 0.3)
      ..lineTo(0, -baseWidth / 2)
      ..lineTo(length, 0);

    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  void _drawMetallicHub(Canvas canvas, double radius) {
    final double hubOuter = radius * 0.09;
    final double hubMid = radius * 0.07;
    final double hubInner = radius * 0.03;

    // Base housing (dark)
    canvas.drawCircle(
      Offset.zero,
      hubOuter,
      Paint()..color = const Color(0xFF0A0A0C),
    );

    // Milled aluminum ring
    canvas.drawCircle(
      Offset.zero,
      hubMid,
      Paint()
        ..shader = const SweepGradient(
          colors: [Color(0xFF8A8A94), Color(0xFFE8E8EC), Color(0xFF8A8A94)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: hubMid))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Center cap (matte black)
    canvas.drawCircle(
      Offset.zero,
      hubInner,
      Paint()..color = const Color(0xFF141418),
    );
    
    // Subtle highlight on cap
    canvas.drawCircle(
      Offset.zero,
      hubInner,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(NeedlePainter oldDelegate) => 
      oldDelegate.speed != speed || 
      oldDelegate.driveMode != driveMode || 
      oldDelegate.useMetric != useMetric;
}
