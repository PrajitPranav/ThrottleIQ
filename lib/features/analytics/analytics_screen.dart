// analytics_screen.dart — Minimalist analytics dashboard.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Track
    canvas.drawArc(rect, _start, _sweep, false,
      Paint()..color = const Color(0xFF141418)
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);

    if (fraction <= 0) return;

    // Solid fill, no neon blur
    canvas.drawArc(rect, _start, _sweep * fraction, false,
      Paint()..color = color
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);
  }

  @override bool shouldRepaint(_ArcPainter o) => o.fraction != fraction;
}

class _Ring extends StatelessWidget {
  final String label;
  final double score;
  final Color  color;
  final double size;
  final double sw;

  const _Ring({required this.label, required this.score,
    required this.color, this.size = 120, this.sw = 8});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: score / 100),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (ctx, v, child) => SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(size, size),
              painter: _ArcPainter(fraction: v, color: color, sw: sw)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${score.round()}',
              style: GoogleFonts.inter(fontSize: size * 0.22,
                  fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: -1.0)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: size * 0.075,
                  letterSpacing: 1.0, color: const Color(0xFF7A7A85), fontWeight: FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final double fraction;

  const _BarChartPainter({required this.values, required this.fraction});

  static const List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<Color> _colors = [
    Color(0xFF4F6B8F), Color(0xFF4F6B8F), Color(0xFF4F6B8F),
    Color(0xFF5A7D65), Color(0xFF9E653F), Color(0xFF8F3232), Color(0xFF5A7D65),
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

      // Dim track
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.04, bw, size.height * 0.78),
          const Radius.circular(2)),
        Paint()..color = const Color(0xFF141418));

      // Active flat bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw, bh), const Radius.circular(2)),
        Paint()..color = _colors[i]);

      final tp = TextPainter(
        text: TextSpan(text: _days[i],
          style: TextStyle(fontSize: 9, color: const Color(0xFF5A5A64),
            fontFamily: GoogleFonts.inter().fontFamily, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, size.height * 0.88));
    }
  }

  @override bool shouldRepaint(_BarChartPainter o) => o.fraction != fraction;
}

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
        const SizedBox(height: 24),
        _header('DRIVING SCORE'),
        const SizedBox(height: 20),
        _Ring(label: 'OVERALL', score: _overall, color: const Color(0xFF5A7D65), size: 160, sw: 10),
        const SizedBox(height: 12),
        Text('Excellent Driver', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0, color: const Color(0xFF5A7D65))),

        const SizedBox(height: 36),
        _header('PERFORMANCE BREAKDOWN'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _Ring(label: 'SMOOTH', score: _smooth, color: Color(0xFF4F6B8F), size: 100, sw: 6),
              _Ring(label: 'BRAKING', score: _braking, color: Color(0xFF5A7D65), size: 100, sw: 6),
              _Ring(label: 'ACCEL', score: _accel, color: Color(0xFF9E653F), size: 100, sw: 6),
            ],
          ),
        ),

        const SizedBox(height: 36),
        _header('WEEKLY ACTIVITY'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E22)),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (ctx, v, child) => CustomPaint(
                painter: _BarChartPainter(values: _weekly, fraction: v),
              ),
            ),
          ),
        ),

        const SizedBox(height: 36),
        _header('DRIVING INSIGHTS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: const [
            _InsightCard(icon: Icons.trending_up_rounded, title: 'Acceleration Profile', body: 'Clean exit zones. Avg 0–100 in 5.2s across 14 sessions.', color: Color(0xFF4F6B8F)),
            _InsightCard(icon: Icons.directions_car_rounded, title: 'Braking Behavior', body: 'Smooth late-braking detected. 91% precision on corner entry.', color: Color(0xFF5A7D65)),
            _InsightCard(icon: Icons.warning_amber_rounded, title: 'Oversteer Events', body: '3 minor events this week. Consider reducing entry speed.', color: Color(0xFF9E653F)),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(children: [
      Text(text, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600,
          letterSpacing: 2.0, color: const Color(0xFF5A5A64))),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Color(0xFF1E1E22), height: 1)),
    ]),
  );
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _InsightCard({required this.icon, required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E22)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 4),
          Text(body, style: GoogleFonts.inter(fontSize: 10, height: 1.4, color: const Color(0xFF7A7A85))),
        ])),
      ]),
    );
  }
}
