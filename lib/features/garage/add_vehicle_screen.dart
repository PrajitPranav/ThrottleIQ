import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/vehicle.dart';
import '../../services/garage_service.dart';
import '../../utils/car_dataset.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADD NEW VEHICLE',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'SEARCH YOUR CAR',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF5A5A64),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. Tata Nexon or BMW M3',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF3A3A44), fontSize: 16),
                filled: true,
                fillColor: const Color(0xFF101014),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E1E22)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E1E22)),
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5A5A64), size: 20),
              ),
              onChanged: (val) {
                setState(() {
                  _suggestions = CarDataset.search(val);
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _suggestions.isEmpty && _searchController.text.isNotEmpty
                ? _noResults()
                : ListView.separated(
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF16161A), height: 1),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF5A5A64), size: 18),
                        onTap: () => _addVehicleFromSuggestion(item),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.car_repair_rounded, color: Color(0xFF1E1E22), size: 48),
          const SizedBox(height: 16),
          Text(
            'NO VEHICLE FOUND',
            style: GoogleFonts.inter(color: const Color(0xFF5A5A64), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching by brand or model name',
            style: GoogleFonts.inter(color: const Color(0xFF3A3A44), fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _addVehicleFromSuggestion(String suggestion) {
    final parts = suggestion.split(' ');
    final make  = parts[0];
    final model = parts.sublist(1).join(' ');
    
    final vehicle = Vehicle(
      id: const Uuid().v4(),
      make: make,
      model: model,
    );

    GarageService().addVehicle(vehicle);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF101014),
        content: Text('$suggestion added to Garage', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
