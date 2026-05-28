import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/trip.dart';
import '../../models/drive_mode.dart';
import '../../services/settings_service.dart';
import '../../services/trip_storage_service.dart';
import '../../services/drive_score_engine.dart';
import '../../widgets/speed_distribution_widget.dart';
import '../../widgets/eta_comparison_card.dart';

// ─── Shared arc painter (also used in analytics_screen) ──────────────────────
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
      Paint()..color = const Color(0xFF141418)
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);

    if (fraction <= 0) return;

    canvas.drawArc(rect, _start, _sweep * fraction, false,
      Paint()..color = color
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);
  }

  @override bool shouldRepaint(_ArcPainter o) => o.fraction != fraction;
}

class _ScoreRing extends StatelessWidget {
  final int    score;
  final String label;
  final Color  color;
  final double size;
  final double sw;

  const _ScoreRing({
    required this.score,
    required this.label,
    required this.color,
    required this.size,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: score / 100),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (ctx, v, _) => SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(fraction: v, color: color, sw: sw),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              score.toString(),
              style: GoogleFonts.inter(
                fontSize: size * 0.24,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: size * 0.075,
                letterSpacing: 1.0,
                color: const Color(0xFF7A7A85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#121214"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#121214"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    final settings  = SettingsService();
    final polylines = _buildPolylines();
    final markers   = _buildMarkers();
    final bounds    = _calculateBounds();

    final int    score      = trip.tripScore;
    final Color  scoreColor = Color(DriveScoreEngine.scoreColorValue(score));
    final String scoreRank  = DriveScoreEngine.rankLabel(score);

    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8F3232), size: 22),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Immersive Map Header ──────────────────────────────────────────
            SizedBox(
              height: 380,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: trip.routePoints.isNotEmpty
                          ? trip.routePoints.first
                          : const LatLng(0, 0),
                      zoom: 14,
                    ),
                    style: _darkMapStyle,
                    onMapCreated: (controller) {
                      if (bounds != null) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          controller.animateCamera(
                            CameraUpdate.newLatLngBounds(bounds, 60),
                          );
                        });
                      }
                    },
                    polylines: polylines,
                    markers: markers,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                  ),
                  // Fade overlay
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xAA060608), Color(0xFF060608)],
                          stops: [0.6, 0.9, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    bottom: 24, left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRIP ANALYSIS',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.0,
                            color: const Color(0xFF5A5A64),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'SESSION ${_formatDate(trip.startTime)}',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: trip.driveMode.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: trip.driveMode.accent.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                trip.driveMode.label,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: trip.driveMode.accent,
                                ),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── High-level Stats Row ──────────────────────────────────
                  Row(
                    children: [
                      _largeStat('DISTANCE', settings.formatDistance(trip.distanceKm), settings.distanceUnit),
                      const SizedBox(width: 32),
                      _largeStat('TOP SPEED', settings.formatSpeed(trip.topSpeedKmh), settings.speedUnit),
                      const SizedBox(width: 32),
                      _largeStat('DURATION', trip.formattedDuration, ''),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ── ETA Efficiency Card ───────────────────────────────────
                  EtaComparisonCard(
                    actualMinutes:   trip.durationMinutes,
                    expectedMinutes: trip.displayExpectedMinutes,
                    startTime:       trip.startTime,
                    endTime:         trip.endTime,
                  ),
                  const SizedBox(height: 32),

                  // ── Speed Distribution ────────────────────────────────────
                  SpeedDistributionWidget(samples: trip.speedSamples),
                  const SizedBox(height: 40),

                  // ── Drive Score Section ───────────────────────────────────
                  _sectionHeader('DRIVE SCORE'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF16161A)),
                    ),
                    child: Row(
                      children: [
                        _ScoreRing(score: score, label: 'OVERALL', color: scoreColor, size: 140, sw: 9),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scoreRank,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: scoreColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scoreDescription(score),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF7A7A85),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Mini sub-scores
                              _miniScoreBar('BRAKING',  trip.brakeScore, const Color(0xFF4F6B8F)),
                              const SizedBox(height: 6),
                              _miniScoreBar('ACCEL',    trip.accelScore, const Color(0xFF5A7D65)),
                              const SizedBox(height: 6),
                              _miniScoreBar('SMOOTHNESS', trip.smoothScore, const Color(0xFF9E653F)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Behavior Analysis Section ─────────────────────────────
                  _sectionHeader('BEHAVIOR ANALYSIS'),
                  const SizedBox(height: 16),
                  _behaviorGrid(settings),
                  const SizedBox(height: 40),

                  // ── Telemetry Details Grid ────────────────────────────────
                  _sectionHeader('TELEMETRY DETAILS'),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.0,
                    children: [
                      _detailStat('AVG SPEED',   settings.formatSpeed(trip.averageSpeedKmh), settings.speedUnit),
                      _detailStat('MAX G-FORCE',  trip.maxGForce.toStringAsFixed(2), 'G'),
                      _detailStat('ROUTE POINTS', trip.routePoints.length.toString(), 'PTS'),
                      _detailStat('SPEED SAMPLES', trip.speedSamples.length.toString(), 'SMPL'),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Behavior grid ──────────────────────────────────────────────────────────
  Widget _behaviorGrid(SettingsService settings) {
    final List<_BehaviorEntry> entries = [
      _BehaviorEntry(
        icon: Icons.directions_car_rounded,
        label: 'TRIP DURATION',
        value: trip.formattedDuration,
        unit: '',
        color: const Color(0xFF4F6B8F),
      ),
      _BehaviorEntry(
        icon: Icons.warning_amber_rounded,
        label: 'HARSH BRAKING',
        value: trip.harshBrakingCount.toString(),
        unit: 'EVENTS',
        color: trip.harshBrakingCount > 0
            ? const Color(0xFF8F3232)
            : const Color(0xFF5A7D65),
      ),
      _BehaviorEntry(
        icon: Icons.speed_rounded,
        label: 'AGGRESSIVE ACCEL',
        value: trip.aggressiveAccelCount.toString(),
        unit: 'EVENTS',
        color: trip.aggressiveAccelCount > 0
            ? const Color(0xFF9E653F)
            : const Color(0xFF5A7D65),
      ),
      _BehaviorEntry(
        icon: Icons.check_circle_outline_rounded,
        label: 'SMOOTH ACCEL',
        value: trip.smoothAccelCount.toString(),
        unit: 'EVENTS',
        color: const Color(0xFF5A7D65),
      ),
      _BehaviorEntry(
        icon: Icons.turn_left_rounded,
        label: 'LEFT TURNS',
        value: trip.leftTurnCount.toString(),
        unit: '',
        color: const Color(0xFF4F6B8F),
      ),
      _BehaviorEntry(
        icon: Icons.turn_right_rounded,
        label: 'RIGHT TURNS',
        value: trip.rightTurnCount.toString(),
        unit: '',
        color: const Color(0xFF4F6B8F),
      ),
      _BehaviorEntry(
        icon: Icons.rotate_right_rounded,
        label: 'SHARP TURNS',
        value: trip.sharpTurnCount.toString(),
        unit: '',
        color: trip.sharpTurnCount > 0
            ? const Color(0xFF9E653F)
            : const Color(0xFF5A7D65),
      ),
      _BehaviorEntry(
        icon: Icons.analytics_outlined,
        label: 'SMOOTH BRAKING',
        value: trip.smoothBrakingCount.toString(),
        unit: 'EVENTS',
        color: const Color(0xFF5A7D65),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: entries.map((e) => _behaviorCard(e)).toList(),
    );
  }

  Widget _behaviorCard(_BehaviorEntry e) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: e.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: e.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(e.icon, size: 11, color: e.color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  e.label,
                  style: GoogleFonts.inter(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                    color: e.color,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                e.value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              if (e.unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  e.unit,
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    color: const Color(0xFF5A5A64),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String text) => Row(children: [
    Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: const Color(0xFF5A5A64),
      ),
    ),
    const SizedBox(width: 12),
    const Expanded(child: Divider(color: Color(0xFF1E1E22), height: 1)),
  ]);

  Widget _miniScoreBar(String label, int score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5A5A64),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: const Color(0xFF16161A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score.toString(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _largeStat(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A5A64),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5A5A64),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _detailStat(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16161A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5A5A64),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit,  style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF5A5A64))),
            ],
          ),
        ],
      ),
    );
  }

  String _scoreDescription(int score) {
    if (score >= 95) return 'Exceptional driving. Near-perfect technique with maximum efficiency.';
    if (score >= 88) return 'Elite performance. Smooth inputs and excellent vehicle control.';
    if (score >= 78) return 'Expert level. Consistent and controlled driving style.';
    if (score >= 65) return 'Skilled driver. Good fundamentals with room to refine.';
    if (score >= 50) return 'Developing. Focus on smoother braking and acceleration.';
    return 'Novice. Reduce harsh inputs for a safer, more efficient drive.';
  }

  Set<Polyline> _buildPolylines() {
    if (trip.routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route_glow'),
        points: trip.routePoints,
        color: const Color(0xFFF97316).withValues(alpha: 0.2),
        width: 16,
        startCap: Cap.roundCap, endCap: Cap.roundCap, jointType: JointType.round,
      ),
      Polyline(
        polylineId: const PolylineId('route_core'),
        points: trip.routePoints,
        color: const Color(0xFFF97316),
        width: 4,
        startCap: Cap.roundCap, endCap: Cap.roundCap, jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    if (trip.routePoints.isEmpty) return {};
    return {
      Marker(
        markerId: const MarkerId('start'),
        position: trip.routePoints.first,
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: trip.routePoints.last,
        infoWindow: const InfoWindow(title: 'End'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  LatLngBounds? _calculateBounds() {
    if (trip.routePoints.isEmpty) return null;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (var p in trip.routePoints) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('DELETE TRIP',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text('Are you sure you want to permanently remove this trip from your history?',
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A94))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              TripStorageService().deleteTrip(trip.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Color(0xFF8F3232))),
          ),
        ],
      ),
    );
  }
}

// ── Data class for behavior grid entries ──────────────────────────────────────
class _BehaviorEntry {
  final IconData icon;
  final String   label;
  final String   value;
  final String   unit;
  final Color    color;
  const _BehaviorEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}
