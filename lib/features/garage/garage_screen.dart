import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/garage_service.dart';
import '../../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GarageService(),
      builder: (context, _) {
        final garage = GarageService();
        final vehicles = garage.vehicles;

        return Scaffold(
          backgroundColor: const Color(0xFF060608),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'MY GARAGE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: vehicles.isEmpty 
            ? _emptyGarage(context)
            : _vehicleList(context, garage, vehicles),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFF97316),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen())),
            child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
          ),
        );
      },
    );
  }

  Widget _emptyGarage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF16161A), size: 100),
          const SizedBox(height: 24),
          Text(
            'YOUR GARAGE IS EMPTY',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: const Color(0xFF5A5A64),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first vehicle to start tracking telemetry',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF3A3A44)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF101014),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF1E1E22)),
              ),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen())),
            child: const Text('ADD VEHICLE'),
          ),
        ],
      ),
    );
  }

  Widget _vehicleList(BuildContext context, GarageService garage, List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final isActive = garage.activeVehicleId == vehicle.id;
        final stats = garage.getVehicleStats(vehicle.id);

        return GestureDetector(
          onTap: () => _showStatsSheet(context, garage, vehicle, isActive, stats),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isActive ? const Color(0xFFF97316).withValues(alpha: 0.3) : const Color(0xFF16161A)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101014),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.directions_car_rounded, color: isActive ? const Color(0xFFF97316) : const Color(0xFF5A5A64)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.make.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 1.0),
                        ),
                        Text(
                          vehicle.model,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFFF97316)),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => garage.selectVehicle(vehicle.id),
                      child: Text('SELECT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64))),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatsSheet(
    BuildContext context,
    GarageService garage,
    Vehicle vehicle,
    bool isActive,
    Map<String, dynamic> stats,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D10),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF1E1E22)),
            left: BorderSide(color: Color(0xFF1E1E22)),
            right: BorderSide(color: Color(0xFF1E1E22)),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C32),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Vehicle identity
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101014),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.directions_car_rounded,
                      color: isActive ? const Color(0xFFF97316) : const Color(0xFF5A5A64), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.make.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 1.0),
                      ),
                      Text(
                        vehicle.model,
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('ACTIVE',
                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFFF97316))),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF101014),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E22)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sheetStat('TRIPS', stats['totalTrips'].toString()),
                  _sheetDivider(),
                  _sheetStat('DISTANCE', '${(stats['totalDistanceKm'] as double).toStringAsFixed(1)} KM'),
                  _sheetDivider(),
                  _sheetStat('AVG SPEED', '${(stats['avgSpeedKmh'] as double).toStringAsFixed(0)} KM/H'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // View full details button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF101014),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF2C2C32)),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                  ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('VIEW FULL DETAILS',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _sheetDivider() => Container(
    width: 1, height: 28,
    color: const Color(0xFF1E1E22),
  );
}
