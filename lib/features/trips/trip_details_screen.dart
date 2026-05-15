import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/trip.dart';
import '../../services/settings_service.dart';
import '../../services/trip_storage_service.dart';
import '../../widgets/speed_distribution_widget.dart';
import '../../widgets/eta_comparison_card.dart';

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
    final settings = SettingsService();
    final Set<Polyline> polylines = _buildPolylines();
    final LatLngBounds? bounds = _calculateBounds();

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
            // Immersive Map Header
            SizedBox(
              height: 380,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: trip.routePoints.isNotEmpty ? trip.routePoints.first : const LatLng(0,0), zoom: 14),
                    style: _darkMapStyle,
                    onMapCreated: (controller) {
                      if (bounds != null) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
                        });
                      }
                    },
                    polylines: polylines,
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
                    bottom: 24,
                    left: 24,
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
                        Text(
                          'SESSION ${_formatDate(trip.startTime)}',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
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
                  // High-level Stats Row
                  Row(
                    children: [
                      _largeStat('DISTANCE', settings.formatDistance(trip.distanceKm), settings.distanceUnit),
                      const SizedBox(width: 40),
                      _largeStat('TOP SPEED', settings.formatSpeed(trip.topSpeedKmh), settings.speedUnit),
                      const SizedBox(width: 40),
                      _largeStat('SCORE', trip.tripScore.toString(), 'PTS'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ETA Efficiency
                  EtaComparisonCard(
                    actualMinutes: trip.durationMinutes,
                    expectedMinutes: trip.expectedDurationMinutes,
                  ),
                  const SizedBox(height: 32),

                  // Speed Distribution
                  SpeedDistributionWidget(samples: trip.speedSamples),
                  const SizedBox(height: 40),

                  // Telemetry Detailed Grid
                  Text(
                    'TELEMETRY DETAILS',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: const Color(0xFF5A5A64),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.0,
                    children: [
                      _detailStat('AVG SPEED', settings.formatSpeed(trip.averageSpeedKmh), settings.speedUnit),
                      _detailStat('DURATION', '${trip.durationMinutes}', 'MIN'),
                      _detailStat('START', _formatTime(trip.startTime), ''),
                      _detailStat('END', _formatTime(trip.endTime), ''),
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

  Widget _largeStat(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64), letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: -1.0)),
            const SizedBox(width: 4),
            Text(unit, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
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
          Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64), letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF5A5A64))),
            ],
          ),
        ],
      ),
    );
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

  LatLngBounds? _calculateBounds() {
    if (trip.routePoints.isEmpty) return null;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (var p in trip.routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  String _formatDate(DateTime dt) => "${dt.day}/${dt.month}/${dt.year}";
  String _formatTime(DateTime dt) => "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('DELETE TRIP', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text('Are you sure you want to permanently remove this trip from your history?', 
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A94))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              TripStorageService().deleteTrip(trip.id);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // go back to list
            },
            child: const Text('DELETE', style: TextStyle(color: Color(0xFF8F3232))),
          ),
        ],
      ),
    );
  }
}

