import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/trip.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;
  
  const TripDetailsScreen({super.key, required this.trip});

  // Dark styling for the static trip map
  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    // Generate simple ETA comparison logic
    // We assume an expected straight-line average speed of 40 km/h in an urban setting.
    // If distance is 0, we can't calculate ETA
    final double expectedHours = trip.distanceKm / 40.0;
    final int expectedMinutes = (expectedHours * 60).round();
    final int actualMinutes = trip.durationMinutes;
    
    final int diff = expectedMinutes - actualMinutes;
    String etaText;
    Color etaColor;
    
    if (diff > 0) {
      etaText = "$diff MIN FASTER";
      etaColor = const Color(0xFF4ADE80); // Green
    } else if (diff < 0) {
      etaText = "${diff.abs()} MIN SLOWER";
      etaColor = const Color(0xFFEF4444); // Red
    } else {
      etaText = "ON TIME";
      etaColor = const Color(0xFF8A8A94); // Gray
    }

    Set<Polyline> polylines = {};
    if (trip.routePoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route_glow'),
        points: trip.routePoints,
        color: const Color(0xFFF97316).withValues(alpha: 0.3), // Orange glow
        width: 14,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
      polylines.add(Polyline(
        polylineId: const PolylineId('route_core'),
        points: trip.routePoints,
        color: const Color(0xFFF97316), // Orange core
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
    }

    // Calculate bounds for the map
    LatLngBounds? bounds;
    if (trip.routePoints.isNotEmpty) {
      double minLat = trip.routePoints[0].latitude;
      double minLng = trip.routePoints[0].longitude;
      double maxLat = trip.routePoints[0].latitude;
      double maxLng = trip.routePoints[0].longitude;

      for (var point in trip.routePoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TRIP ANALYSIS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Static Map View
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E1E22)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: trip.routePoints.isEmpty 
                  ? const Center(child: Text("No GPS Route Data", style: TextStyle(color: Colors.white)))
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: trip.routePoints.first,
                        zoom: 14,
                      ),
                      style: _darkMapStyle,
                      onMapCreated: (controller) {
                        if (bounds != null) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            controller.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 40));
                          });
                        }
                      },
                      polylines: polylines,
                      markers: {
                        Marker(
                          markerId: const MarkerId('start'),
                          position: trip.routePoints.first,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('end'),
                          position: trip.routePoints.last,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
              ),
            ),
            
            const SizedBox(height: 16),

            // ETA Comparison Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF101014),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E22)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ETA ANALYSIS',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: const Color(0xFF5A5A64),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        etaText,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: etaColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.insights_rounded, color: etaColor.withValues(alpha: 0.5), size: 32),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Detailed Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'DISTANCE', value: trip.distanceKm.toStringAsFixed(1), unit: 'KM')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'DURATION', value: trip.durationMinutes.toString(), unit: 'MIN')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'AVG SPEED', value: trip.averageSpeedKmh.toStringAsFixed(0), unit: 'KM/H')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'TOP SPEED', value: trip.topSpeedKmh.toStringAsFixed(0), unit: 'KM/H')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'SCORE', value: trip.tripScore.toString(), unit: 'PTS')),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()), // Empty slot for balance
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatCard({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF16161A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: const Color(0xFF5A5A64),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A7A85),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
