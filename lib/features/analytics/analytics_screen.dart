// analytics_screen.dart — Full driving analytics dashboard.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Score arc painter ────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double fraction;
  final Color  color;
  final double sw;

  const _ArcPainter({required this.fraction, required this.color, required this.sw});

  static const double _start = math.pi * 0.65;
  static const double _sweep = math.pi * 1.70;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 * 0.86;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawArc(rect, _start, _sweep, false,
      Paint()..color = const Color(0xFF161620)
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);

    if (fraction <= 0) return;

    canvas.drawArc(rect, _start, _sweep * fraction, false,
      Paint()..color = color.withValues(alpha: 0.35)
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw + 4
             ..strokeCap = StrokeCap.round
             ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawArc(rect, _start, _sweep * fraction, false,
      Paint()..color = color
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);
  }

  @override bool shouldRepaint(_ArcPainter o) => o.fraction != fraction;
}

// ── Animated score ring ──────────────────────────────────────────────────────
class _Ring extends StatelessWidget {
  final String label;
  final double score;   // 0–100
  final Color  color;
  final double size;
  final double sw;

  const _Ring({required this.label, required this.score,
    required this.color, this.size = 120, this.sw = 8});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: score / 100),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (ctx, v, child) => SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(size, size),
              painter: _ArcPainter(fraction: v, color: color, sw: sw)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${score.round()}',
              style: GoogleFonts.rajdhani(fontSize: size * 0.22,
                  fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.92))),
            Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.exo2(fontSize: size * 0.075,
                  letterSpacing: 1.2, color: const Color(0xFF444454))),
          ]),
        ]),
      ),
    );
  }
}

// ── Bar chart painter ────────────────────────────────────────────────────────
class _BarChartPainter extends CustomPainter {
  final List<double> values; // 0–1 each
  final double fraction;

  const _BarChartPainter({required this.values, required this.fraction});

  static const List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<Color> _colors = [
    Color(0xFF4A9ECC), Color(0xFF4A9ECC), Color(0xFF4A9ECC),
    Color(0xFF26A65B), Color(0xFFE08020), Color(0xFFCC1800), Color(0xFF26A65B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final int n = values.length;
    final double bw = size.width / (n * 2 - 1);
    final double gap = bw;

    for (int i = 0; i < n; i++) {
      final double x  = i * (bw + gap);
      final double bh = size.height * 0.78 * values[i] * fraction;
      final double y  = size.height * 0.82 - bh;

      // Dim bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.04, bw, size.height * 0.78),
          const Radius.circular(3)),
        Paint()..color = const Color(0xFF161620));

      // Active bar
      final paint = Paint()
        ..color = _colors[i]
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw, bh), const Radius.circular(3)),
        paint);

      // Day label
      final tp = TextPainter(
        text: TextSpan(text: _days[i],
          style: TextStyle(fontSize: 9, color: const Color(0xFF3A3A4A),
            fontFamily: GoogleFonts.exo2().fontFamily)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, size.height * 0.88));
    }
  }

  @override bool shouldRepaint(_BarChartPainter o) => o.fraction != fraction;
}

// ── Main analytics screen ────────────────────────────────────────────────────
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const double _overall   = 87;
  static const double _smooth    = 82;
  static const double _braking   = 91;
  static const double _accel     = 79;
  static const List<double> _weekly = [0.72, 0.85, 0.68, 0.91, 0.77, 0.88, 0.87];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 20),

        // ── Overall score ring ─────────────────────────────────────────────
        _header('DRIVING SCORE'),
        const SizedBox(height: 16),
        _Ring(label: 'OVERALL', score: _overall, color: const Color(0xFF26A65B),
            size: 160, sw: 11),
        const SizedBox(height: 8),
        Text('Excellent Driver', style: GoogleFonts.rajdhani(
            fontSize: 14, letterSpacing: 2.0, color: const Color(0xFF26A65B))),

        const SizedBox(height: 28),

        // ── Sub-score rings ───────────────────────────────────────────────
        _header('PERFORMANCE BREAKDOWN'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Ring(label: 'SMOOTH', score: _smooth,
                  color: const Color(0xFF4A9ECC), size: 100, sw: 7)
                  .animate(delay: 100.ms).fadeIn(duration: 400.ms),
              _Ring(label: 'BRAKING', score: _braking,
                  color: const Color(0xFF26A65B), size: 100, sw: 7)
                  .animate(delay: 200.ms).fadeIn(duration: 400.ms),
              _Ring(label: 'ACCEL', score: _accel,
                  color: const Color(0xFFE08020), size: 100, sw: 7)
                  .animate(delay: 300.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Weekly activity ───────────────────────────────────────────────
        _header('WEEKLY ACTIVITY'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1A1A22)),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (ctx, v, child) => CustomPaint(
                painter: _BarChartPainter(values: _weekly, fraction: v),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Insight cards ─────────────────────────────────────────────────
        _header('DRIVING INSIGHTS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _insightCard(Icons.trending_up_rounded, 'Acceleration Profile',
                'Clean exit zones. Avg 0–100 in 5.2s across 14 sessions.',
                const Color(0xFF4A9ECC), 0),
            _insightCard(Icons.directions_car_rounded, 'Braking Behavior',
                'Smooth late-braking detected. 91% precision on corner entry.',
                const Color(0xFF26A65B), 100),
            _insightCard(Icons.warning_amber_rounded, 'Oversteer Events',
                '3 minor events this week. Consider reducing entry speed.',
                const Color(0xFFE08020), 200),
            _insightCard(Icons.local_fire_department_rounded, 'Best Lap Trend',
                'Improving. Last 5 sessions show 0.8% lap time reduction.',
                const Color(0xFFCC1800), 300),
          ]),
        ),

        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Text(text, style: GoogleFonts.exo2(fontSize: 8, fontWeight: FontWeight.w700,
          letterSpacing: 3.0, color: const Color(0xFF3A3A4A))),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Color(0xFF1A1A22), height: 1)),
    ]),
  );

  Widget _insightCard(IconData icon, String title, String body, Color color, int delayMs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.rajdhani(fontSize: 14,
              fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.88))),
          const SizedBox(height: 4),
          Text(body, style: GoogleFonts.exo2(fontSize: 10, height: 1.5,
              color: const Color(0xFF444454))),
        ])),
      ]),
    ).animate(delay: delayMs.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
