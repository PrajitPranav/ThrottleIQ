// gauge_painter.dart — Luxury analog gauge face painter for ThrottleIQ.
//
// Draws (in order):
//   1. Deep graphite layered background
//   2. Outer chrome bezel (multi-ring with specular glint)
//   3. Arc track groove
//   4. Colored speed zone arcs (normal / sport / danger)
//   5. Tick marks — non-uniform scale (20 km/h steps to 200, then 50 to 300)
//   6. Speed labels at key values
//   7. Inner concave shadow
//   8. Speed-reactive ambient glow
//
// SCALE DESIGN
// ─────────────────────────────────────────────────────────────────────────────
// The scale is intentionally non-uniform:
//   0–200  → major tick every 20 km/h  (10 divisions)
//   200–300 → major tick at 250 and 300  (2 more divisions)
//
// To implement this cleanly we work with a *logical* 0–1 fraction that maps
// to the visual angle, not directly to km/h.  The mapping function
// _speedToFraction() converts a km/h value to its visual position on the arc.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class GaugePainter extends CustomPainter {
  final double speed; // 0–300

  // ─── Geometry ──────────────────────────────────────────────────────────────
  // Arc spans 270° starting from bottom-left.
  // In Flutter canvas coordinates: angle 0 = 3 o'clock, clockwise.
  // We want 6 o'clock +45° = 225° from 3 o'clock = 225° * π/180 radians
  static const double _startDeg = 225.0;
  static const double _sweepDeg = 270.0;
  static const double _startRad = _startDeg * math.pi / 180.0;
  static const double _sweepRad = _sweepDeg * math.pi / 180.0;

  const GaugePainter({required this.speed});

  // ─── Scale mapping ─────────────────────────────────────────────────────────
  // The scale has two visual segments:
  //   Segment A: 0–200 km/h  occupies 78% of the arc sweep
  //   Segment B: 200–300 km/h occupies 22% of the arc sweep
  // This gives the "compressed" high-speed zone look of Porsche clusters.
  static const double _seg1End    = 200.0; // km/h
  static const double _maxSpeed   = 300.0;
  static const double _seg1Frac   = 0.78;  // fraction of arc for 0–200
  static const double _seg2Frac   = 0.22;  // fraction of arc for 200–300

  static double speedToFraction(double kmh) {
    final double v = kmh.clamp(0.0, _maxSpeed);
    if (v <= _seg1End) {
      return (v / _seg1End) * _seg1Frac;
    } else {
      return _seg1Frac + ((v - _seg1End) / (_maxSpeed - _seg1End)) * _seg2Frac;
    }
  }

  static double speedToAngle(double kmh) {
    return _startRad + _sweepRad * speedToFraction(kmh);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width  / 2;
    final double cy = size.height / 2;
    final double r  = math.min(cx, cy);

    _drawBackground(canvas, cx, cy, r);
    _drawOuterBezel(canvas, cx, cy, r);
    _drawArcTrack(canvas, cx, cy, r);
    _drawArcZones(canvas, cx, cy, r);
    _drawTickMarks(canvas, cx, cy, r);
    _drawLabels(canvas, cx, cy, r);
    _drawInnerShadow(canvas, cx, cy, r);
    _drawGlassReflection(canvas, cx, cy, r);
    _drawAmbientGlow(canvas, cx, cy, r);
  }

  // ─── 1. BACKGROUND ─────────────────────────────────────────────────────────

  void _drawBackground(Canvas canvas, double cx, double cy, double r) {
    // Base fill
    canvas.drawCircle(
      Offset(cx, cy), r * 0.97,
      Paint()..color = AppColors.backgroundSurface,
    );

    // Concave radial gradient — lighter at top-center (light source), dark edge
    canvas.drawCircle(
      Offset(cx, cy), r * 0.97,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.1,
          colors: const [
            Color(0xFF1C1C22), // lighter center
            Color(0xFF0B0B0F), // dark mid
            Color(0xFF050507), // deep black edge
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
  }

  // ─── 2. OUTER CHROME BEZEL ─────────────────────────────────────────────────

  void _drawOuterBezel(Canvas canvas, double cx, double cy, double r) {
    // Main bezel ring — dark metallic
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = AppColors.chromeOuter
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04,
    );

    // Outer edge bright specular line — simulates machined edge catch
    canvas.drawCircle(
      Offset(cx, cy), r - r * 0.005,
      Paint()
        ..color = AppColors.chromeHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Inner bezel separation line
    canvas.drawCircle(
      Offset(cx, cy), r - r * 0.04,
      Paint()
        ..color = AppColors.chromeScratch
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Second darker groove
    canvas.drawCircle(
      Offset(cx, cy), r * 0.93,
      Paint()
        ..color = AppColors.chromeInner
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.012,
    );
  }

  // ─── 3. ARC TRACK GROOVE ───────────────────────────────────────────────────

  void _drawArcTrack(Canvas canvas, double cx, double cy, double r) {
    // Dark groove that the colored arcs sit inside
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.81),
      _startRad, _sweepRad, false,
      Paint()
        ..color = AppColors.arcTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.048
        ..strokeCap = StrokeCap.butt,
    );
  }

  // ─── 4. COLORED ZONE ARCS ──────────────────────────────────────────────────

  void _drawArcZones(Canvas canvas, double cx, double cy, double r) {
    final double arcR = r * 0.81;
    final double arcW = r * 0.026;

    // Normal zone: 0–160 (cool blue)
    _arcSegment(canvas, cx, cy, arcR, arcW, 0, 160,
        AppColors.arcNormal.withValues(alpha: 0.80));

    // Sport zone: 160–250 (amber)
    _arcSegment(canvas, cx, cy, arcR, arcW, 160, 250,
        AppColors.arcSport.withValues(alpha: 0.85));

    // Danger zone: 250–300 (hard red, full opacity)
    _arcSegment(canvas, cx, cy, arcR, arcW, 250, 300,
        AppColors.arcDanger.withValues(alpha: 0.95));
  }

  void _arcSegment(
    Canvas canvas, double cx, double cy,
    double rad, double strokeW,
    double fromKmh, double toKmh, Color color,
  ) {
    final double startA = speedToAngle(fromKmh);
    final double endA   = speedToAngle(toKmh);
    final double gap    = 0.008; // tiny gap between zones

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: rad),
      startA + gap, endA - startA - gap * 2, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt,
    );
  }

  // ─── 5. TICK MARKS ─────────────────────────────────────────────────────────
  //
  // Scale:
  //   0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 250, 300
  //   Plus minor ticks every 10 km/h in the 0–200 band,
  //   and one minor tick at 225 km/h in the 200–300 band.

  void _drawTickMarks(Canvas canvas, double cx, double cy, double r) {
    final double outerR  = r * 0.90;
    final double majorL  = r * 0.072; // major tick length
    final double midL    = r * 0.044; // mid tick (every 10 km/h in 0-200)
    final double minorL  = r * 0.028; // minor tick (every 5 km/h)

    // Build the full tick list: (speed, isMajor, length)
    final List<(double, bool, double)> ticks = [];

    // 0–200: major every 20, mid every 10, minor every 5
    for (double v = 0; v <= 200.0; v += 5.0) {
      final bool isMajor = (v % 20 == 0);
      final bool isMid   = (!isMajor) && (v % 10 == 0);
      final double len   = isMajor ? majorL : (isMid ? midL : minorL);
      ticks.add((v, isMajor, len));
    }

    // 200–300: major at 250 and 300, minor at 225 and 275
    for (final double v in [225.0, 250.0, 275.0, 300.0]) {
      final bool isMajor = (v == 250.0 || v == 300.0);
      ticks.add((v, isMajor, isMajor ? majorL : midL));
    }

    for (final (double v, bool isMajor, double len) in ticks) {
      final double angle = speedToAngle(v);
      final double cosA  = math.cos(angle);
      final double sinA  = math.sin(angle);

      // Color logic
      Color tickColor;
      if (isMajor) {
        if (v >= 250) {
          tickColor = AppColors.tickDanger;
        } else if (v >= 160) {
          tickColor = AppColors.tickSport;
        } else {
          tickColor = AppColors.tickMajor;
        }
      } else {
        if (v >= 250) {
          tickColor = AppColors.tickDanger.withValues(alpha: 0.45);
        } else if (v >= 160) {
          tickColor = AppColors.tickSport.withValues(alpha: 0.45);
        } else {
          tickColor = AppColors.tickMinor;
        }
      }

      final double strokeW = isMajor ? 1.8 : 1.0;

      canvas.drawLine(
        Offset(cx + cosA * (outerR - len), cy + sinA * (outerR - len)),
        Offset(cx + cosA * outerR,         cy + sinA * outerR),
        Paint()
          ..color      = tickColor
          ..strokeWidth = strokeW
          ..strokeCap  = StrokeCap.round,
      );
    }
  }

  // ─── 6. SPEED LABELS ───────────────────────────────────────────────────────

  void _drawLabels(Canvas canvas, double cx, double cy, double r) {
    // Labels at: 0, 40, 80, 120, 160, 200, 250, 300
    final List<int> labelValues = [0, 40, 80, 120, 160, 200, 250, 300];
    final double labelR = r * 0.695;

    for (final int v in labelValues) {
      final double angle = speedToAngle(v.toDouble());
      final double lx = cx + math.cos(angle) * labelR;
      final double ly = cy + math.sin(angle) * labelR;

      Color labelColor;
      if (v >= 250) {
        labelColor = AppColors.tickDanger.withValues(alpha: 0.92);
      } else if (v >= 160) {
        labelColor = AppColors.tickSport.withValues(alpha: 0.88);
      } else {
        labelColor = AppColors.tickMajor.withValues(alpha: 0.80);
      }

      final double fontSize = r * 0.088;

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: v.toString(),
          style: TextStyle(
            color:       labelColor,
            fontSize:    fontSize,
            fontWeight:  FontWeight.w300, // thin luxury weight
            letterSpacing: -0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  // ─── 7. INNER SHADOW ───────────────────────────────────────────────────────

  void _drawInnerShadow(Canvas canvas, double cx, double cy, double r) {
    // Creates the "concave glass dome" illusion — darker at edges
    canvas.drawCircle(
      Offset(cx, cy), r * 0.90,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.62),
          ],
          stops: const [0.0, 0.60, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.90)),
    );
  }

  // ─── 8. GLASS REFLECTION ───────────────────────────────────────────────────

  void _drawGlassReflection(Canvas canvas, double cx, double cy, double r) {
    // A subtle crescent highlight at the top — simulates overhead light
    // reflecting off the glass dome cover of the instrument cluster.
    final double reflR = r * 0.76;

    // Clip to the gauge face area first
    canvas.save();
    canvas.clipPath(Path()..addOval(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.90),
    ));

    // Small white crescent at top
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy - r * 0.04), radius: reflR),
      math.pi * 1.15, // start ~210° from x-axis
      math.pi * 0.70, // sweep 126°
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.022)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
    );

    canvas.restore();
  }

  // ─── 9. AMBIENT GLOW ───────────────────────────────────────────────────────

  void _drawAmbientGlow(Canvas canvas, double cx, double cy, double r) {
    // Glow color and intensity track the speed zone
    Color glowColor;
    double glowAlpha;

    if (speed < 160) {
      glowColor = AppColors.arcNormal;
      glowAlpha = 0.03 + (speed / 160) * 0.09;
    } else if (speed < 250) {
      glowColor = AppColors.arcSport;
      glowAlpha = 0.10 + ((speed - 160) / 90) * 0.12;
    } else {
      glowColor = AppColors.arcDanger;
      glowAlpha = 0.20 + ((speed - 250) / 50) * 0.18;
    }

    // Outer halo (blurred ring outside bezel)
    canvas.drawCircle(
      Offset(cx, cy), r * 0.97,
      Paint()
        ..color = glowColor.withValues(alpha: glowAlpha * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, r * 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05,
    );

    // Inner arc glow that follows the active zone
    canvas.drawCircle(
      Offset(cx, cy), r * 0.82,
      Paint()
        ..color = glowColor.withValues(alpha: glowAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.032,
    );
  }

  @override
  bool shouldRepaint(GaugePainter old) => old.speed != speed;
}
