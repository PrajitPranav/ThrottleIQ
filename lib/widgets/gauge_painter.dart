// gauge_painter.dart — German-engineered premium analog gauge face.
// Focus on physical realism, depth, and sharp precision.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/drive_mode.dart';

class GaugePainter extends CustomPainter {
  final double speed;
  final DriveMode driveMode;

  const GaugePainter({required this.speed, required this.driveMode});

  // 0–200 km/h covers the first 78% of the arc.
  // 200–300 km/h covers the remaining 22%.
  static const double _splitSpeed = 200.0;
  static const double _splitArcRatio = 0.78;

  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.50;

  static double speedToAngle(double spd) {
    if (spd <= _splitSpeed) {
      return _startAngle + _sweepAngle * _splitArcRatio * (spd / _splitSpeed);
    } else {
      final double over = spd - _splitSpeed;
      final double fraction = over / 100.0;
      final double start = _startAngle + _sweepAngle * _splitArcRatio;
      return start + _sweepAngle * (1.0 - _splitArcRatio) * fraction;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    _drawBezelAndDial(canvas, center, radius);
    _drawTracks(canvas, center, radius);
    _drawTicksAndLabels(canvas, center, radius);
    _drawGlassReflection(canvas, center, radius);
  }

  void _drawBezelAndDial(Canvas canvas, Offset center, double radius) {
    // Outer metallic ring (bezel)
    canvas.drawCircle(
      center,
      radius * 0.98,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFF2C2C32),
            Color(0xFF141418),
            Color(0xFF4A4A52),
            Color(0xFF141418),
            Color(0xFF2C2C32),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          transform: GradientRotation(math.pi / 4),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // Deep matte graphite dial
    canvas.drawCircle(
      center,
      radius * 0.96,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0F0F12), Color(0xFF08080A)],
          stops: [0.4, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Inner milled aluminum depth ring
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = const Color(0xFF18181A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      radius * 0.72 - 1.5,
      Paint()
        ..color = const Color(0xFF08080A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawTracks(Canvas canvas, Offset center, double radius) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius * 0.85);
    final double trackWidth = radius * 0.035;

    // Base dark mechanical track
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFF16161A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth
        ..strokeCap = StrokeCap.square,
    );

    // Active speed fill (matte, aggressive)
    final double currentAngle = speedToAngle(speed);
    final double activeSweep = currentAngle - _startAngle;

    if (activeSweep > 0) {
      Color fillModeColor = driveMode.accent;

      canvas.drawArc(
        rect,
        _startAngle,
        activeSweep,
        false,
        Paint()
          ..color = fillModeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth
          ..strokeCap = StrokeCap.square,
      );
    }
  }

  void _drawTicksAndLabels(Canvas canvas, Offset center, double radius) {
    final double outer = radius * 0.85; // Matches track
    final double innerMajor = radius * 0.78;
    final double innerMinor = radius * 0.81;
    final double innerSub = radius * 0.83;
    final double labelRadius = radius * 0.64;

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    for (int s = 0; s <= 300; s += 5) {
      // Scale compression logic
      if (s > 200 && s % 10 != 0 && s != 225 && s != 250 && s != 275) continue;

      final double angle = speedToAngle(s.toDouble());
      final double cosA = math.cos(angle);
      final double sinA = math.sin(angle);

      bool isMajor = (s <= 200 && s % 20 == 0) || s == 250 || s == 300;
      bool isMinor = (s <= 200 && s % 10 == 0) || s == 225 || s == 275;

      final double currentInner = isMajor ? innerMajor : (isMinor ? innerMinor : innerSub);

      final Offset p1 = center + Offset(cosA * outer, sinA * outer);
      final Offset p2 = center + Offset(cosA * currentInner, sinA * currentInner);

      Color tColor = const Color(0xFF3E3E46);
      double tWidth = 1.0;

      if (isMajor) {
        tColor = Colors.white;
        tWidth = driveMode == DriveMode.eco ? 1.0 : 2.0;
        if (s >= 250 && (driveMode == DriveMode.sport || driveMode == DriveMode.sportPlus)) {
          tColor = driveMode.accent;
        }
      } else if (isMinor) {
        tWidth = 1.5;
        tColor = driveMode == DriveMode.eco ? const Color(0xFF5A5A64) : const Color(0xFF8A8A94);
        if (s >= 250 && (driveMode == DriveMode.sport || driveMode == DriveMode.sportPlus)) {
          tColor = driveMode.accent.withValues(alpha: 0.8);
        }
      } else {
        if (s >= 250 && (driveMode == DriveMode.sport || driveMode == DriveMode.sportPlus)) {
          tColor = driveMode.accent.withValues(alpha: 0.5);
        }
      }

      canvas.drawLine(
        p1, p2,
        Paint()
          ..color = tColor
          ..strokeWidth = tWidth
          ..strokeCap = StrokeCap.square,
      );

      // Labels at major intervals
      if ((s <= 200 && s % 40 == 0) || s == 250 || s == 300) {
        tp.text = TextSpan(
          text: s.toString(),
          style: TextStyle(
            color: s >= 250 && (driveMode == DriveMode.sport || driveMode == DriveMode.sportPlus) 
                ? driveMode.accent : Colors.white,
            fontSize: radius * 0.13,
            fontWeight: driveMode == DriveMode.eco ? FontWeight.w400 : FontWeight.w600,
            letterSpacing: -0.5,
          ),
        );
        tp.layout();
        final Offset textOffset = center + Offset(cosA * labelRadius, sinA * labelRadius);
        tp.paint(canvas, textOffset - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  void _drawGlassReflection(Canvas canvas, Offset center, double radius) {
    // Subtle top glass curve reflection
    final Rect rect = Rect.fromCircle(center: center, radius: radius * 0.95);
    final Path path = Path()
      ..addArc(rect, math.pi * 1.0, math.pi * 1.0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x08FFFFFF), Colors.transparent],
          stops: [0.0, 0.4],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.driveMode != driveMode;
  }
}
