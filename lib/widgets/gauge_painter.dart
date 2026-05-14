// gauge_painter.dart — Custom painter that draws the premium analog gauge face.
//
// This painter is responsible for ALL visual elements except the needle:
//   • The deep black layered background
//   • The chrome outer bezel ring
//   • The graduated arc track (colored zones)
//   • Tick marks (major + minor) with automotive typography
//   • Number labels at major intervals
//   • Ambient glow / shadow rings
//
// Using a CustomPainter instead of relying on Syncfusion defaults gives us
// full pixel-level control over the premium "German automotive cluster" aesthetic.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class GaugePainter extends CustomPainter {
  // The current animated speed value (0–240).
  // Repaint is triggered every frame by the AnimationController.
  final double speed;

  // Maximum speed the gauge displays
  static const double maxSpeed = 240;

  // Gauge arc geometry
  // Start angle: 225° from x-axis (bottom-left), sweep 270°
  static const double startAngleDeg = 135;  // clockwise from 3 o'clock = 225° from positive x
  static const double sweepDeg      = 270;  // total sweep of the arc

  // We work in radians internally
  static const double _startRad = (startAngleDeg + 90) * math.pi / 180;
  static const double _sweepRad = sweepDeg * math.pi / 180;

  const GaugePainter({required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;   // center x
    final double cy = size.height / 2;  // center y
    final double r  = math.min(cx, cy); // outer radius of paint area

    _drawBackground(canvas, cx, cy, r);
    _drawOuterBezel(canvas, cx, cy, r);
    _drawArcTrack(canvas, cx, cy, r);
    _drawArcZones(canvas, cx, cy, r);
    _drawTickMarks(canvas, cx, cy, r);
    _drawLabels(canvas, cx, cy, r);
    _drawInnerShadow(canvas, cx, cy, r);
    _drawAmbientGlow(canvas, cx, cy, r);
  }

  // ─── 1. DEEP BLACK LAYERED BACKGROUND ────────────────────────────────────────

  void _drawBackground(Canvas canvas, double cx, double cy, double r) {
    // Outermost fill — solid very dark graphite
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.98,
      Paint()..color = AppColors.backgroundSurface,
    );

    // Subtle radial gradient from slightly lighter center → dark edge
    // Creates an illusion of depth / concave glass
    final Paint gradPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF18181E),
          AppColors.backgroundSurface,
          const Color(0xFF080809),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r * 0.98, gradPaint);
  }

  // ─── 2. CHROME OUTER BEZEL ───────────────────────────────────────────────────

  void _drawOuterBezel(Canvas canvas, double cx, double cy, double r) {
    // Outermost ring — very dark
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = AppColors.chromeOuter
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.035,
    );

    // Second ring — slightly lighter (brushed chrome highlight)
    canvas.drawCircle(
      Offset(cx, cy),
      r - r * 0.022,
      Paint()
        ..color = AppColors.chromeScratch
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Inner chrome ring — closes the bezel visually
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.92,
      Paint()
        ..color = AppColors.chromeInner
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  // ─── 3. ARC TRACK (INACTIVE BACKGROUND) ─────────────────────────────────────

  void _drawArcTrack(Canvas canvas, double cx, double cy, double r) {
    final double trackR = r * 0.82;
    final double trackW = r * 0.045;

    final Paint trackPaint = Paint()
      ..color = AppColors.arcTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackW
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: trackR),
      _startRad,
      _sweepRad,
      false,
      trackPaint,
    );
  }

  // ─── 4. COLORED SPEED ZONE ARCS ──────────────────────────────────────────────

  void _drawArcZones(Canvas canvas, double cx, double cy, double r) {
    // Arc zones are painted at a slightly smaller radius than the track
    // so they sit inside the dark track groove.
    final double arcR = r * 0.82;
    final double arcW = r * 0.028;

    // Green zone: 0–80
    _drawArcSegment(canvas, cx, cy, arcR, arcW, 0,   80,  AppColors.arcGreen.withValues(alpha: 0.85));

    // Amber zone: 80–160
    _drawArcSegment(canvas, cx, cy, arcR, arcW, 80,  160, AppColors.arcAmber.withValues(alpha: 0.85));

    // Red zone: 160–240
    _drawArcSegment(canvas, cx, cy, arcR, arcW, 160, 240, AppColors.arcRed.withValues(alpha: 0.9));
  }

  void _drawArcSegment(
    Canvas canvas, double cx, double cy,
    double radius, double strokeWidth,
    double fromSpeed, double toSpeed, Color color,
  ) {
    final double startFrac = fromSpeed / maxSpeed;
    final double endFrac   = toSpeed   / maxSpeed;

    // Add a tiny gap between zones (0.5°) so they look separated
    final double gapRad = 0.009;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      _startRad + _sweepRad * startFrac + gapRad,
      _sweepRad * (endFrac - startFrac) - gapRad * 2,
      false,
      paint,
    );
  }

  // ─── 5. TICK MARKS ───────────────────────────────────────────────────────────

  void _drawTickMarks(Canvas canvas, double cx, double cy, double r) {
    // Major ticks at every 20 km/h (0, 20, 40 … 240)
    // Minor ticks at every 4 km/h (5 minor between each major = interval of 4)

    final double tickOuterR = r * 0.90; // where the outer end of tick touches
    final double majorLen   = r * 0.075;
    final double minorLen   = r * 0.038;

    // We draw ticks from 0 to 240 in steps of 4 (minor) and mark 20s as major
    const double step = 4.0; // km/h per minor tick
    for (double v = 0; v <= maxSpeed + 0.1; v += step) {
      final bool isMajor = (v % 20 == 0);
      final double fraction = v / maxSpeed;
      final double angle = _startRad + _sweepRad * fraction;

      // Direction vector from center toward tick
      final double dx = math.cos(angle);
      final double dy = math.sin(angle);

      final double len    = isMajor ? majorLen : minorLen;
      final double width  = isMajor ? 2.0 : 1.0;

      // Choose tick color: red zone major ticks get a red tint
      Color tickColor;
      if (isMajor) {
        tickColor = v >= 160 ? AppColors.tickRedZone : AppColors.tickMajor;
      } else {
        tickColor = v >= 160
            ? AppColors.tickRedZone.withValues(alpha: 0.4)
            : AppColors.tickMinor;
      }

      final Paint paint = Paint()
        ..color = tickColor
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      final Offset outer = Offset(cx + dx * tickOuterR, cy + dy * tickOuterR);
      final Offset inner = Offset(cx + dx * (tickOuterR - len), cy + dy * (tickOuterR - len));

      canvas.drawLine(inner, outer, paint);
    }
  }

  // ─── 6. SPEED LABELS ─────────────────────────────────────────────────────────

  void _drawLabels(Canvas canvas, double cx, double cy, double r) {
    // Labels at every 40 km/h: 0, 40, 80, 120, 160, 200, 240
    final double labelR = r * 0.70;

    for (int v = 0; v <= 240; v += 40) {
      final double fraction = v / maxSpeed;
      final double angle    = _startRad + _sweepRad * fraction;

      final double lx = cx + math.cos(angle) * labelR;
      final double ly = cy + math.sin(angle) * labelR;

      final Color labelColor = v >= 160 ? AppColors.tickRedZone : AppColors.tickMajor;

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: v.toString(),
          style: TextStyle(
            color: labelColor.withValues(alpha: 0.9),
            fontSize: r * 0.10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Center the label on the computed point
      tp.paint(
        canvas,
        Offset(lx - tp.width / 2, ly - tp.height / 2),
      );
    }
  }

  // ─── 7. INNER SHADOW (DEPTH) ─────────────────────────────────────────────────

  void _drawInnerShadow(Canvas canvas, double cx, double cy, double r) {
    // A radial gradient from transparent center → dark edge creates the illusion
    // of a concave "glass dome" surface — essential for a premium look.
    final Paint shadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.55),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.91));

    canvas.drawCircle(Offset(cx, cy), r * 0.91, shadowPaint);
  }

  // ─── 8. AMBIENT GLOW ─────────────────────────────────────────────────────────

  void _drawAmbientGlow(Canvas canvas, double cx, double cy, double r) {
    // The glow intensity and color shift with speed:
    //   0–80   → green-ish very subtle
    //   80–160 → amber
    //   160+   → red
    Color glowColor;
    double glowOpacity;

    if (speed < 80) {
      glowColor   = AppColors.arcGreen;
      glowOpacity = 0.04 + (speed / 80) * 0.08;
    } else if (speed < 160) {
      glowColor   = AppColors.arcAmber;
      glowOpacity = 0.10 + ((speed - 80) / 80) * 0.10;
    } else {
      glowColor   = AppColors.arcRed;
      glowOpacity = 0.18 + ((speed - 160) / 80) * 0.14;
    }

    // Outer halo on the bezel
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.98,
      Paint()
        ..color = Colors.transparent
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, r * 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04,
    );

    // Speed-reactive inner glow ring
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.83,
      Paint()
        ..color = glowColor.withValues(alpha: glowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.035,
    );
  }

  // Always repaint — the animation controller drives continuous repaints
  @override
  bool shouldRepaint(GaugePainter oldDelegate) => true;
}
