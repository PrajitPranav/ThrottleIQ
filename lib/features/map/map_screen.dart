import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/gps_service.dart';
import '../../models/drive_mode.dart';

class MapScreen extends StatefulWidget {
  final DriveMode driveMode;
  const MapScreen({super.key, required this.driveMode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  
  // Basic dark automotive map styling
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#8a8a8a"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#3c3c3c"}]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [{"color": "#4e4e4e"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    GpsService().addListener(_onGpsUpdate);
  }

  @override
  void dispose() {
    GpsService().removeListener(_onGpsUpdate);
    super.dispose();
  }

  Future<void> _onGpsUpdate() async {
    if (!mounted) return;
    final gps = GpsService();
    if (gps.isActive && gps.currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(gps.currentPosition!.latitude, gps.currentPosition!.longitude),
          zoom: 16.5,
          tilt: 45.0, // Cinematic tilt
          bearing: gps.currentPosition!.heading, // Face direction of travel
        ),
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final gps = GpsService();
    
    // Fallback default target if GPS is disabled or hasn't locked yet
    final initialTarget = gps.currentPosition != null 
      ? LatLng(gps.currentPosition!.latitude, gps.currentPosition!.longitude)
      : const LatLng(37.7749, -122.4194); // Default to SF

    Set<Polyline> polylines = {};
    if (gps.routePoints.isNotEmpty) {
      // Glow line underneath
      polylines.add(Polyline(
        polylineId: const PolylineId('route_glow'),
        points: gps.routePoints,
        color: widget.driveMode.accent.withValues(alpha: 0.3),
        width: 14,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
      
      // Core bright line
      polylines.add(Polyline(
        polylineId: const PolylineId('route_core'),
        points: gps.routePoints,
        color: widget.driveMode.accent,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
    }

    Set<Marker> markers = {};
    if (gps.currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_pos'),
        position: LatLng(gps.currentPosition!.latitude, gps.currentPosition!.longitude),
        // A simple custom marker can be achieved by using the icon property
        // For premium feel, the default marker is tinted to accent color
        icon: BitmapDescriptor.defaultMarkerWithHue(
          // Approximate hue based on drive mode accent
          HSVColor.fromColor(widget.driveMode.accent).hue,
        ),
      ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            style: _darkMapStyle,
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            polylines: polylines,
            markers: markers,
            myLocationEnabled: false, // We use custom marker
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          if (!gps.isActive)
            Container(
              color: const Color(0xFF050507).withValues(alpha: 0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101014),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E22)),
                  ),
                  child: const Text(
                    'TELEMETRY STANDBY\nPRESS START TO TRACK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8A8A94),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
