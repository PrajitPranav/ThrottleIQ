// trip_summary_card.dart — Premium TripRank-inspired shareable summary card.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip.dart';
import '../models/drive_mode.dart';
import '../services/settings_service.dart';


class TripSummaryCard extends StatelessWidget {
  final Trip trip;

  const TripSummaryCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final date = _formatDate(trip.startTime);
    final startCoord = trip.routePoints.isNotEmpty
        ? '${trip.routePoints.first.latitude.toStringAsFixed(4)}°, ${trip.routePoints.first.longitude.toStringAsFixed(4)}°'
        : 'No GPS data';

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E24), width: 1),
        boxShadow: [
          BoxShadow(
            color: trip.driveMode.accent.withValues(alpha: 0.06),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: trip.driveMode.accent.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(color: trip.driveMode.accent.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trip.driveMode.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: trip.driveMode.accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    trip.driveMode.label,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: trip.driveMode.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TRIP SUMMARY',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: const Color(0xFF5A5A64),
                  ),
                ),
                const Spacer(),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A4A52),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Mini route preview ──────────────────────────────────────────────
          if (trip.routePoints.length >= 2)
            SizedBox(
              height: 120,
              child: ClipRRect(
                child: CustomPaint(
                  painter: _RoutePreviewPainter(
                    points: trip.routePoints,
                    accentColor: trip.driveMode.accent,
                  ),
                  child: Container(color: const Color(0xFF080809)),
                ),
              ),
            )
          else
            Container(
              height: 80,
              color: const Color(0xFF080809),
              child: Center(
                child: Text(
                  'NO ROUTE DATA',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: const Color(0xFF2A2A30),
                  ),
                ),
              ),
            ),

          // ── Stats grid ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: distance + duration
                Row(
                  children: [
                    Expanded(child: _statCell(
                      icon: Icons.straighten_rounded,
                      label: 'DISTANCE',
                      value: settings.formatDistance(trip.distanceKm),
                      unit: settings.distanceUnit,
                      accent: trip.driveMode.accent,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _statCell(
                      icon: Icons.timer_outlined,
                      label: 'DURATION',
                      value: _formatDuration(trip.durationMinutes),
                      unit: '',
                      accent: trip.driveMode.accent,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: avg speed + top speed
                Row(
                  children: [
                    Expanded(child: _statCell(
                      icon: Icons.speed_rounded,
                      label: 'AVG SPEED',
                      value: settings.formatSpeed(trip.averageSpeedKmh),
                      unit: settings.speedUnit,
                      accent: trip.driveMode.accent,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _statCell(
                      icon: Icons.rocket_launch_outlined,
                      label: 'TOP SPEED',
                      value: settings.formatSpeed(trip.topSpeedKmh),
                      unit: settings.speedUnit,
                      accent: trip.driveMode.accent,
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Start location footer ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101014),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1A1A20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: trip.driveMode.accent.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START LOCATION',
                            style: GoogleFonts.inter(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: const Color(0xFF5A5A64),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            startCoord,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: accent.withValues(alpha: 0.7)),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF5A5A64),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A5A64),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _formatDuration(int mins) {
    if (mins < 60) return '${mins}M';
    return '${mins ~/ 60}H ${mins % 60}M';
  }
}

// ── Custom painter: lightweight route polyline preview ──────────────────────

class _RoutePreviewPainter extends CustomPainter {
  final List<LatLng> points;
  final Color accentColor;

  _RoutePreviewPainter({required this.points, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Compute bounding box
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final latSpan = (maxLat - minLat) == 0 ? 0.001 : (maxLat - minLat);
    final lngSpan = (maxLng - minLng) == 0 ? 0.001 : (maxLng - minLng);

    final padding = 20.0;
    final drawW = size.width - padding * 2;
    final drawH = size.height - padding * 2;

    Offset toOffset(LatLng p) {
      final x = padding + ((p.longitude - minLng) / lngSpan) * drawW;
      // Flip Y: latitude increases upward but canvas Y increases downward
      final y = padding + ((maxLat - p.latitude) / latSpan) * drawH;
      return Offset(x, y);
    }

    // Glow pass
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Core pass
    final corePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Sample up to 300 points to keep it performant
    final step = math.max(1, (points.length / 300).ceil());
    final sampled = [
      for (int i = 0; i < points.length; i += step) points[i],
      points.last,
    ];

    final path = Path();
    path.moveTo(toOffset(sampled.first).dx, toOffset(sampled.first).dy);
    for (final p in sampled.skip(1)) {
      final o = toOffset(p);
      path.lineTo(o.dx, o.dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);

    // Start dot
    final startOff = toOffset(points.first);
    canvas.drawCircle(startOff, 5,
        Paint()..color = const Color(0xFF4ADE80));
    canvas.drawCircle(startOff, 5,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // End dot
    final endOff = toOffset(points.last);
    canvas.drawCircle(endOff, 5,
        Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(endOff, 5,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter old) =>
      old.points != points || old.accentColor != accentColor;
}
