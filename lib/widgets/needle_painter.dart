// needle_painter.dart — Premium razor-sharp analog needle for ThrottleIQ.
//
// Design language: Porsche + BMW M hybrid
//
// Features:
//   • Vivid orange-red gradient body (wide at hub, razor-thin at tip)
//   • Luminous hot-red glowing tip
//   • Subtle motion-blur shadow behind the needle
//   • Deep machined pivot knob with specular micro-dot
//   • Weighted dark counterweight tail
//
// The needle angle uses the SAME non-uniform speedToAngle() mapping as
// GaugePainter so needle and scale are always in perfect alignment.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'gauge_painter.dart'; // for speedToAngle()

class NeedlePainter extends CustomPainter {
  // Current speed value (0–300)
  final double speed;

  const NeedlePainter({required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width  / 2;
    final double cy = size.height / 2;
    final double r  = math.min(cx, cy);

    // Get the needle angle using the SAME mapping as the gauge face
    final double angle = GaugePainter.speedToAngle(speed.clamp(0, 300));

    // Primary direction of the needle (toward the scale)
    final double ndx = math.cos(angle);
    final double ndy = math.sin(angle);

    // Perpendicular direction (for needle width)
    final double px = -ndy;
    final double py =  ndx;

    // Draw order: shadow first, then body, then glow tip, then knob on top
    _drawShadow(canvas, cx, cy, r, ndx, ndy, px, py, angle);
    _drawNeedleBody(canvas, cx, cy, r, ndx, ndy, px, py);
    _drawGlowTip(canvas, cx, cy, r, ndx, ndy);
    _drawTail(canvas, cx, cy, r, ndx, ndy, px, py);
    _drawKnob(canvas, cx, cy, r);
  }

  // ─── SHADOW (motion blur feel) ─────────────────────────────────────────────

  void _drawShadow(
    Canvas canvas, double cx, double cy, double r,
    double ndx, double ndy, double px, double py, double angle,
  ) {
    // A slightly offset, blurred, wider version of the needle body
    // painted at low opacity — creates the illusion of motion depth.
    final double tipR  = r * 0.79;
    final double baseR = r * 0.10;

    final Offset tip  = Offset(cx + ndx * tipR,  cy + ndy * tipR);
    final Offset base = Offset(cx + ndx * baseR, cy + ndy * baseR);

    final double baseHalf = r * 0.022;
    final double tipHalf  = r * 0.003;

    final Path shadowPath = Path()
      ..moveTo(tip.dx  + px * tipHalf,  tip.dy  + py * tipHalf)
      ..lineTo(tip.dx  - px * tipHalf,  tip.dy  - py * tipHalf)
      ..lineTo(base.dx - px * baseHalf, base.dy - py * baseHalf)
      ..lineTo(base.dx + px * baseHalf, base.dy + py * baseHalf)
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  // ─── NEEDLE BODY ───────────────────────────────────────────────────────────

  void _drawNeedleBody(
    Canvas canvas, double cx, double cy, double r,
    double ndx, double ndy, double px, double py,
  ) {
    final double tipR  = r * 0.79;  // tip distance from center
    final double baseR = r * 0.10;  // how far back from center the needle widens

    final Offset tip  = Offset(cx + ndx * tipR,  cy + ndy * tipR);
    final Offset base = Offset(cx + ndx * baseR, cy + ndy * baseR);

    // Tapered shape — wide at base, knife-edge at tip
    final double baseHalf = r * 0.016;
    final double tipHalf  = r * 0.0015;

    final Path bodyPath = Path()
      ..moveTo(tip.dx  + px * tipHalf,  tip.dy  + py * tipHalf)
      ..lineTo(tip.dx  - px * tipHalf,  tip.dy  - py * tipHalf)
      ..lineTo(base.dx - px * baseHalf, base.dy - py * baseHalf)
      ..lineTo(base.dx + px * baseHalf, base.dy + py * baseHalf)
      ..close();

    // Orange-red gradient along the needle length
    // Creates the premium heated-metal look
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        // Gradient runs from base (darker) to tip (brighter red)
        begin: Alignment(
          (cx + ndx * baseR - cx) / r,
          (cy + ndy * baseR - cy) / r,
        ),
        end: Alignment(
          (cx + ndx * tipR - cx) / r,
          (cy + ndy * tipR - cy) / r,
        ),
        colors: const [
          Color(0xFFFF5500), // base — warm orange
          Color(0xFFFF3300), // mid — orange-red
          Color(0xFFFF1100), // tip — vivid red
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(base, tip),
      );

    canvas.drawPath(bodyPath, bodyPaint);

    // Thin bright highlight line along the center-top of the needle
    // Simulates the specular edge of a polished metal needle
    canvas.drawLine(
      Offset(base.dx + px * (baseHalf * 0.25), base.dy + py * (baseHalf * 0.25)),
      Offset(tip.dx  + px * tipHalf,           tip.dy  + py * tipHalf),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );
  }

  // ─── GLOWING TIP ───────────────────────────────────────────────────────────

  void _drawGlowTip(
    Canvas canvas, double cx, double cy, double r,
    double ndx, double ndy,
  ) {
    // A small blurred circle at the very tip of the needle — the "hot point"
    final double tipR = r * 0.79;
    final Offset tipPos = Offset(cx + ndx * tipR, cy + ndy * tipR);

    canvas.drawCircle(
      tipPos, r * 0.018,
      Paint()
        ..color = AppColors.needleTip.withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.025),
    );

    canvas.drawCircle(
      tipPos, r * 0.006,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  // ─── COUNTERWEIGHT TAIL ────────────────────────────────────────────────────

  void _drawTail(
    Canvas canvas, double cx, double cy, double r,
    double ndx, double ndy, double px, double py,
  ) {
    final double tailLen  = r * 0.14;
    final double tailHalf = r * 0.020;

    final Offset tailEnd  = Offset(cx - ndx * tailLen, cy - ndy * tailLen);
    final Offset tailBase = Offset(cx + ndx * r * 0.03, cy + ndy * r * 0.03);

    final Path tailPath = Path()
      ..moveTo(tailEnd.dx  + px * (tailHalf * 0.3), tailEnd.dy  + py * (tailHalf * 0.3))
      ..lineTo(tailEnd.dx  - px * (tailHalf * 0.3), tailEnd.dy  - py * (tailHalf * 0.3))
      ..lineTo(tailBase.dx - px * tailHalf,          tailBase.dy - py * tailHalf)
      ..lineTo(tailBase.dx + px * tailHalf,          tailBase.dy + py * tailHalf)
      ..close();

    canvas.drawPath(tailPath, Paint()..color = AppColors.needleTail);
  }

  // ─── PIVOT KNOB ────────────────────────────────────────────────────────────

  void _drawKnob(Canvas canvas, double cx, double cy, double r) {
    final double knobR = r * 0.062;

    // Drop shadow
    canvas.drawCircle(
      Offset(cx, cy), knobR * 1.7,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Dark machined base with subtle radial gradient
    canvas.drawCircle(
      Offset(cx, cy), knobR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: const [
            Color(0xFF323238),
            Color(0xFF0C0C10),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: knobR)),
    );

    // Red accent ring — thin and precise
    canvas.drawCircle(
      Offset(cx, cy), knobR,
      Paint()
        ..color = AppColors.needleKnobRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.011,
    );

    // Inner darker ring
    canvas.drawCircle(
      Offset(cx, cy), knobR * 0.58,
      Paint()
        ..color = const Color(0xFF080810)
        ..style = PaintingStyle.fill,
    );

    // Specular micro-dot highlight
    canvas.drawCircle(
      Offset(cx - knobR * 0.30, cy - knobR * 0.32),
      knobR * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(NeedlePainter old) => old.speed != speed;
}
