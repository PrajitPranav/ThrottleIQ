// analytics_screen.dart — Minimalist analytics dashboard.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/trip_storage_service.dart';
import '../../models/trip.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TripStorageService(),
      builder: (context, _) {
        final trips = TripStorageService().trips;
        
        if (trips.isEmpty) {
          return _emptyAnalytics();
        }

        // Calculate Overall Stats
        final double avgScore = trips.fold(0.0, (sum, t) => sum + t.tripScore) / trips.length;
        final double avgSmooth = trips.fold(0.0, (sum, t) => sum + t.smoothScore) / trips.length;
        final double avgSpeedScore = trips.fold(0.0, (sum, t) => sum + t.speedScore) / trips.length;
        final double avgEfficiency = trips.fold(0.0, (sum, t) => sum + t.efficiencyScore) / trips.length;

        // Calculate Weekly Activity (Last 7 days)
        final now = DateTime.now();
        final List<double> weeklyData = List.filled(7, 0.0);
        for (var i = 0; i < 7; i++) {
          final day = now.subtract(Duration(days: 6 - i));
          final dayTrips = trips.where((t) => 
            t.startTime.year == day.year && 
            t.startTime.month == day.month && 
            t.startTime.day == day.day
          );
          if (dayTrips.isNotEmpty) {
            weeklyData[i] = dayTrips.fold(0.0, (sum, t) => sum + t.distanceKm) / 50.0; // Normalize to 50km max for bar height
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            const SizedBox(height: 24),
            _header('DRIVING SCORE'),
            const SizedBox(height: 20),
            _Ring(label: 'OVERALL', score: avgScore, color: const Color(0xFF5A7D65), size: 160, sw: 10),
            const SizedBox(height: 12),
            Text(_getRankText(avgScore), style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0, color: const Color(0xFF5A7D65))),

            const SizedBox(height: 36),
            _header('PERFORMANCE BREAKDOWN'),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Ring(label: 'SMOOTH', score: avgSmooth, color: const Color(0xFF4F6B8F), size: 100, sw: 6),
                  _Ring(label: 'SPEED', score: avgSpeedScore, color: const Color(0xFF5A7D65), size: 100, sw: 6),
                  _Ring(label: 'EFFICIENCY', score: avgEfficiency, color: const Color(0xFF9E653F), size: 100, sw: 6),
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
                    painter: _BarChartPainter(values: weeklyData, fraction: v),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
            _header('DRIVING INSIGHTS'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: _generateInsights(trips)),
            ),
            const SizedBox(height: 32),
          ]),
        );
      },
    );
  }

  Widget _emptyAnalytics() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 80, color: Color(0xFF16161A)),
          const SizedBox(height: 24),
          Text(
            'NO DATA YET',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: const Color(0xFF5A5A64)),
          ),
          const SizedBox(height: 12),
          Text('Complete a few trips to see your driving analysis', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF3A3A44))),
        ],
      ),
    );
  }

  String _getRankText(double score) {
    if (score > 90) return 'ELITE DRIVER';
    if (score > 80) return 'EXPERT DRIVER';
    if (score > 60) return 'SKILLED DRIVER';
    return 'NOVICE DRIVER';
  }

  List<Widget> _generateInsights(List<Trip> trips) {
    final List<Widget> insights = [];
    final double avgMaxG = trips.fold(0.0, (sum, t) => sum + t.maxGForce) / trips.length;
    
    if (avgMaxG > 1.2) {
      insights.add(const _InsightCard(icon: Icons.warning_amber_rounded, title: 'High G-Force Detected', body: 'Your cornering forces are quite high. Consider smoother entries to maintain tire grip.', color: Color(0xFF8F3232)));
    } else {
      insights.add(const _InsightCard(icon: Icons.check_circle_outline_rounded, title: 'Excellent Smoothness', body: 'Consistent G-Force management. Your driving style minimizes vehicle wear.', color: Color(0xFF5A7D65)));
    }

    final double avgTopSpeed = trips.fold(0.0, (sum, t) => sum + t.topSpeedKmh) / trips.length;
    if (avgTopSpeed > 100) {
      insights.add(const _InsightCard(icon: Icons.speed_rounded, title: 'Speed Profile', body: 'High average top speeds recorded. Ensure adherence to local track limits.', color: Color(0xFF9E653F)));
    }

    return insights;
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
