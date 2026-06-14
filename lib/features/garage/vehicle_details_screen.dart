import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/vehicle.dart';
import '../../models/drive_mode.dart';
import '../../services/garage_service.dart';
import '../../services/settings_service.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
    // Listen for garage changes to refresh vehicle data (e.g. after manual stat edits)
    GarageService().addListener(_onGarageChanged);
  }

  void _onGarageChanged() {
    final updated = GarageService().vehicles.where((v) => v.id == _vehicle.id);
    if (updated.isNotEmpty && mounted) {
      setState(() => _vehicle = updated.first);
    }
  }

  @override
  void dispose() {
    GarageService().removeListener(_onGarageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garage = GarageService();
    final settings = SettingsService();
    final stats = garage.getVehicleStats(_vehicle.id);

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
          'VEHICLE OVERVIEW',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF5A5A64), size: 20),
            tooltip: 'Edit Stats',
            onPressed: () => _showEditStatsDialog(context, garage, settings, stats),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final stats = GarageService().getVehicleStats(_vehicle.id);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _vehicleHeader(),
                const SizedBox(height: 48),
                _lifetimeStats(stats, settings),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _vehicleHeader() {
    return Column(
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF101014),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1E1E22), width: 2),
          ),
          child: const Center(child: Icon(Icons.directions_car_rounded, size: 64, color: Color(0xFF5A5A64))),
        ),
        const SizedBox(height: 24),
        Text(
          _vehicle.make.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 3.0),
        ),
        const SizedBox(height: 8),
        Text(
          _vehicle.model,
          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: -1.0),
        ),
      ],
    );
  }

  Widget _lifetimeStats(Map<String, dynamic> stats, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIFETIME PERFORMANCE',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: const Color(0xFF5A5A64)),
              ),
              GestureDetector(
                onTap: () => _showEditStatsDialog(context, GarageService(), settings, stats),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101014),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF1E1E22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFFF97316), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'EDIT',
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _statRow('TOTAL DISTANCE', settings.formatDistance(stats['totalDistanceKm']), settings.distanceUnit),
          _divider(),
          _statRow('TRIPS COMPLETED', stats['totalTrips'].toString(), 'SESSIONS'),
          _divider(),
          _statRow('AVERAGE SPEED', settings.formatSpeed(stats['avgSpeedKmh']), settings.speedUnit),
          _divider(),
          _statRow('TOP SPEED OVERALL', settings.formatSpeed(stats['topSpeedKmh']), settings.speedUnit),
          _divider(),
          _statRow('DRIVING DURATION', _formatDuration(stats['totalDurationMinutes']), ''),
          _divider(),
          _modeStatRow('FAVORITE DRIVE MODE', stats['favoriteMode'] as DriveMode?),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF8A8A94))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFF16161A), height: 1);

  String _formatDuration(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) return '${h}H ${m}M';
    return '${m}M';
  }

  /// Accepts nullable DriveMode — shows "N/A" when no trips have been recorded yet.
  Widget _modeStatRow(String label, DriveMode? mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF8A8A94))),
          if (mode == null)
            Text(
              'N/A',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF3A3A44)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mode.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: mode.accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                mode.label,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: mode.accent),
              ),
            ),
        ],
      ),
    );
  }

  // ── Edit Stats Dialog ──────────────────────────────────────────────────────

  void _showEditStatsDialog(
    BuildContext context,
    GarageService garage,
    SettingsService settings,
    Map<String, dynamic> stats,
  ) {
    // Controllers pre-filled with existing manual values
    final distCtrl = TextEditingController(
      text: _vehicle.manualDistanceKm > 0
          ? settings.convertDistance(_vehicle.manualDistanceKm).toStringAsFixed(1)
          : '',
    );
    final speedCtrl = TextEditingController(
      text: _vehicle.manualTopSpeedKmh > 0
          ? settings.convertSpeed(_vehicle.manualTopSpeedKmh).toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E1E22)),
        ),
        title: Text(
          'MANUAL STATS',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add lifetime stats manually. These are added on top of GPS-tracked trip data.',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF5A5A64)),
            ),
            const SizedBox(height: 20),
            _editField(
              controller: distCtrl,
              label: 'MANUAL DISTANCE (${settings.distanceUnit})',
              hint: '0.0',
            ),
            const SizedBox(height: 16),
            _editField(
              controller: speedCtrl,
              label: 'MANUAL TOP SPEED (${settings.speedUnit})',
              hint: '0',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final rawDist = double.tryParse(distCtrl.text) ?? 0.0;
              final rawSpeed = double.tryParse(speedCtrl.text) ?? 0.0;
              // Convert from display unit back to km
              final distKm = settings.useMetric ? rawDist : rawDist / 0.621371;
              final speedKmh = settings.useMetric ? rawSpeed : rawSpeed / 0.621371;
              await garage.updateVehicleStats(
                _vehicle.id,
                distanceKm: distKm,
                topSpeedKmh: speedKmh,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'SAVE',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: const Color(0xFF5A5A64)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF3A3A44), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFF101014),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E1E22)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E1E22)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF97316)),
            ),
          ),
        ),
      ],
    );
  }
}
