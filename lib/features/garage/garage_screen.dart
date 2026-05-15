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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleDetailsScreen(vehicle: vehicle))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isActive ? const Color(0xFFF97316).withValues(alpha: 0.3) : const Color(0xFF16161A)),
            ),
            child: Column(
              children: [
                Padding(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF101014),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallStat('TRIPS', stats['totalTrips'].toString()),
                      _smallStat('DISTANCE', '${(stats['totalDistanceKm'] as double).toStringAsFixed(1)} KM'),
                      _smallStat('AVG SPEED', '${(stats['avgSpeedKmh'] as double).toStringAsFixed(0)} KM/H'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: const Color(0xFF5A5A64), letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}
