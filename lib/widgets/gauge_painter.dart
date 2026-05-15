// gauge_painter.dart — German-engineered premium analog gauge face.
// Focus on physical realism, depth, and sharp precision.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/drive_mode.dart';

class GaugePainter extends CustomPainter {
  final double speed;
  final DriveMode driveMode;
  final bool useMetric;

  const GaugePainter({required this.speed, required this.driveMode, required this.useMetric});

  // KM/H scale: 0-300, split at 200
  // MPH scale: 0-200, split at 120
  double get _maxSpeed => useMetric ? 300.0 : 200.0;
  double get _splitSpeed => useMetric ? 200.0 : 120.0;
  static const double _splitArcRatio = 0.78;

  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.50;

  static double speedToAngle(double spd, bool metric) {
    final double maxVal = metric ? 300.0 : 200.0;
    final double splitVal = metric ? 200.0 : 120.0;
    final double overSplitMax = metric ? 100.0 : 80.0;

    if (spd <= splitVal) {
      return _startAngle + _sweepAngle * _splitArcRatio * (spd / splitVal);
    } else {
      final double over = spd - splitVal;
      final double fraction = over / overSplitMax;
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
    final double currentAngle = speedToAngle(speed, useMetric);
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

    final int step = useMetric ? 5 : 4;
    final int majorStep = useMetric ? 20 : 20;
    final int labelStep = useMetric ? 40 : 20;

    for (int s = 0; s <= _maxSpeed; s += step) {
      // Scale compression logic
      if (useMetric) {
        if (s > 200 && s % 10 != 0 && s != 225 && s != 250 && s != 275) continue;
      } else {
        if (s > 120 && s % 10 != 0 && s != 140 && s != 160 && s != 180) continue;
      }

      final double angle = speedToAngle(s.toDouble(), useMetric);
      final double cosA = math.cos(angle);
      final double sinA = math.sin(angle);

      bool isMajor = (s <= _splitSpeed && s % majorStep == 0) || s == _maxSpeed || (useMetric && s == 250);
      bool isMinor = (s <= _splitSpeed && s % (majorStep ~/ 2) == 0) || (!useMetric && s % 10 == 0);

      if (useMetric) {
         isMajor = (s <= 200 && s % 20 == 0) || s == 250 || s == 300;
         isMinor = (s <= 200 && s % 10 == 0) || s == 225 || s == 275;
      } else {
         isMajor = (s <= 120 && s % 20 == 0) || s == 160 || s == 200;
         isMinor = (s <= 120 && s % 10 == 0) || s == 140 || s == 180;
      }

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
      bool shouldLabel = false;
      if (useMetric) {
        shouldLabel = (s <= 200 && s % 40 == 0) || s == 250 || s == 300;
      } else {
        shouldLabel = (s <= 120 && s % 20 == 0) || s == 160 || s == 200;
      }

      if (shouldLabel) {
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
    return oldDelegate.speed != speed || 
           oldDelegate.driveMode != driveMode || 
           oldDelegate.useMetric != useMetric;
  }
}
