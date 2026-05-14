// needle_painter.dart — Custom painter for the premium analog speedometer needle.
//
// The needle is drawn separately from the gauge face so it can be redrawn
// every animation frame without touching the expensive background layers.
//
// Design:
//   • Tapered polished-silver body (wide at knob, fine at tip)
//   • Glowing red tip (like a heated filament)
//   • Dark counterweight tail behind the pivot
//   • Layered knob: dark base + red accent ring + polished highlight dot

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class NeedlePainter extends CustomPainter {
  // The current needle angle value in the range 0–240 (km/h)
  final double speed;

  // Maximum value for angle calculation
  static const double maxSpeed = 240.0;

  // Gauge geometry — must match GaugePainter exactly
  static const double startAngleDeg = 135;
  static const double sweepDeg      = 270;
  static const double _startRad     = (startAngleDeg + 90) * math.pi / 180;
  static const double _sweepRad     = sweepDeg * math.pi / 180;

  const NeedlePainter({required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width  / 2;
    final double cy = size.height / 2;
    final double r  = math.min(cx, cy);

    // Calculate the angle this speed corresponds to on the dial
    final double fraction   = (speed / maxSpeed).clamp(0.0, 1.0);
    final double needleAngle = _startRad + _sweepRad * fraction;

    // Unit direction vector for the needle direction
    final double dx = math.cos(needleAngle);
    final double dy = math.sin(needleAngle);

    // Perpendicular direction (for needle width)
    final double px = -dy;
    final double py =  dx;

    _drawNeedleBody(canvas, cx, cy, r, dx, dy, px, py);
    _drawNeedleTail(canvas, cx, cy, r, dx, dy, px, py);
    _drawKnob(canvas, cx, cy, r);
  }

  // ─── NEEDLE BODY ─────────────────────────────────────────────────────────────

  void _drawNeedleBody(
    Canvas canvas, double cx, double cy, double r,
    double dx, double dy, double px, double py,
  ) {
    final double tipR  = r * 0.78;  // distance from center to needle tip
    final double baseR = r * 0.12;  // distance needle extends "before" center

    // Needle tip point (toward the dial scale)
    final Offset tip     = Offset(cx + dx * tipR,  cy + dy * tipR);
    // Pivot area base point
    final Offset pivotFwd = Offset(cx + dx * baseR, cy + dy * baseR);

    // Half-widths: widest at pivot, tapers to near-zero at tip
    final double baseHalf  = r * 0.012;
    final double tipHalf   = r * 0.002;

    // Build a tapered quadrilateral for the needle body
    final Path bodyPath = Path()
      ..moveTo(tip.dx + px * tipHalf, tip.dy + py * tipHalf)
      ..lineTo(tip.dx - px * tipHalf, tip.dy - py * tipHalf)
      ..lineTo(pivotFwd.dx - px * baseHalf, pivotFwd.dy - py * baseHalf)
      ..lineTo(pivotFwd.dx + px * baseHalf, pivotFwd.dy + py * baseHalf)
      ..close();

    // Main needle body — polished silver with a subtle linear gradient
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-px, -py),
        end:   Alignment( px,  py),
        colors: const [
          Color(0xFFAAAAAE), // shadow side
          Color(0xFFE8E8EC), // highlight side
          Color(0xFFCCCCCC), // mid
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromPoints(
        Offset(cx - r * baseHalf * 2, cy - r * baseHalf * 2),
        Offset(cx + r * baseHalf * 2, cy + r * baseHalf * 2),
      ));

    canvas.drawPath(bodyPath, bodyPaint);

    // Tip highlight
    final double glowLen = r * 0.14;
    final Offset glowBase = Offset(cx + dx * (tipR - glowLen), cy + dy * (tipR - glowLen));

    final Path tipPath = Path()
      ..moveTo(tip.dx + px * tipHalf, tip.dy + py * tipHalf)
      ..lineTo(tip.dx - px * tipHalf, tip.dy - py * tipHalf)
      ..lineTo(glowBase.dx - px * (tipHalf * 1.5), glowBase.dy - py * (tipHalf * 1.5))
      ..lineTo(glowBase.dx + px * (tipHalf * 1.5), glowBase.dy + py * (tipHalf * 1.5))
      ..close();

    final Paint tipPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(dx - 1, dy - 1),
        end:   Alignment(dx,     dy),
        colors: [
          AppColors.needleTip,
          AppColors.needleTip.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromPoints(glowBase, tip));

    canvas.drawPath(tipPath, tipPaint);

    // Subtle drop shadow
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // ─── NEEDLE TAIL (COUNTERWEIGHT) ─────────────────────────────────────────────

  void _drawNeedleTail(
    Canvas canvas, double cx, double cy, double r,
    double dx, double dy, double px, double py,
  ) {
    // Short, wider dark section going opposite to the needle direction
    final double tailLen  = r * 0.16;
    final double tailHalf = r * 0.018;

    final Offset tailTip  = Offset(cx - dx * tailLen, cy - dy * tailLen);
    final Offset pivotFwd = Offset(cx + dx * r * 0.04, cy + dy * r * 0.04);

    final Path tailPath = Path()
      ..moveTo(tailTip.dx + px * (tailHalf * 0.4), tailTip.dy + py * (tailHalf * 0.4))
      ..lineTo(tailTip.dx - px * (tailHalf * 0.4), tailTip.dy - py * (tailHalf * 0.4))
      ..lineTo(pivotFwd.dx - px * tailHalf, pivotFwd.dy - py * tailHalf)
      ..lineTo(pivotFwd.dx + px * tailHalf, pivotFwd.dy + py * tailHalf)
      ..close();

    canvas.drawPath(
      tailPath,
      Paint()..color = AppColors.needleTail,
    );
  }

  // ─── PIVOT KNOB ───────────────────────────────────────────────────────────────

  void _drawKnob(Canvas canvas, double cx, double cy, double r) {
    final double knobR = r * 0.065;

    // Outer shadow halo
    canvas.drawCircle(
      Offset(cx, cy),
      knobR * 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Dark base cap
    canvas.drawCircle(
      Offset(cx, cy),
      knobR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: const [
            Color(0xFF2E2E36),
            Color(0xFF0E0E12),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: knobR)),
    );

    // Red accent ring around the knob
    canvas.drawCircle(
      Offset(cx, cy),
      knobR,
      Paint()
        ..color = AppColors.needleKnobRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.012,
    );

    // Tiny specular highlight dot
    canvas.drawCircle(
      Offset(cx - knobR * 0.28, cy - knobR * 0.3),
      knobR * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  // Always repaint — driven by AnimationController
  @override
  bool shouldRepaint(NeedlePainter oldDelegate) => oldDelegate.speed != speed;
}
