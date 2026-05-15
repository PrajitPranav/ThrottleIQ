// garage_screen.dart — Premium minimal vehicle showcase.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 24),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _vehicleCard()),
        const SizedBox(height: 32),
        _header('VEHICLE STATS'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, childAspectRatio: 2.0,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _Stat(label: 'ODOMETER',  value: '12,847',  unit: 'KM',    icon: Icons.speed_rounded,         color: Color(0xFF4F6B8F)),
              _Stat(label: 'TOP SPEED', value: '284',     unit: 'KM/H',  icon: Icons.north_rounded,         color: Color(0xFF8F3232)),
              _Stat(label: 'SESSIONS',  value: '47',      unit: 'TRIPS', icon: Icons.route_rounded,         color: Color(0xFF5A7D65)),
              _Stat(label: 'FAV MODE',  value: 'SPORT+',  unit: '',      icon: Icons.tune_rounded,          color: Color(0xFF9E653F)),
              _Stat(label: 'AVG SCORE', value: '87',      unit: '/ 100', icon: Icons.star_rounded,          color: Color(0xFF5A7D65)),
              _Stat(label: 'BEST LAP',  value: '01:42.3', unit: 'MM:SS', icon: Icons.timer_rounded,         color: Color(0xFF4F6B8F)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _header('SESSION RECORDS'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: const [
            _Record(label: 'Longest Trip',     value: '1 hr 14 min', icon: Icons.schedule_rounded,     color: Color(0xFF4F6B8F)),
            _Record(label: 'Highest G-Force',  value: '1.42 G',      icon: Icons.compress_rounded,     color: Color(0xFF8F3232)),
            _Record(label: 'Night Sessions',   value: '18 drives',   icon: Icons.nights_stay_rounded,  color: Color(0xFF9E653F)),
            _Record(label: 'Highway Distance', value: '2,140 KM',    icon: Icons.straight_rounded,     color: Color(0xFF5A7D65)),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _vehicleCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(height: 200, child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/one.png', fit: BoxFit.cover,
              errorBuilder: (ctx, obj, e) => Container(
                color: const Color(0xFF0A0A0C),
                child: const Center(child: Icon(Icons.directions_car_rounded,
                    size: 80, color: Color(0xFF1E1E22))))),
            const DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF101014)], stops: [0.5, 1.0]))),
            Positioned(top: 14, right: 14, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF8F3232),
                borderRadius: BorderRadius.circular(4)),
              child: Text('SPORT+', style: GoogleFonts.inter(
                  fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Colors.white)),
            )),
          ])),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('PANAMERA GTS', style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.5,
                  color: Colors.white))),
              Text('2024', style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF5A5A64), fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 4),
            Text('"GHOST"  •  Night Black Metallic', style: GoogleFonts.inter(
                fontSize: 10, color: const Color(0xFF7A7A85))),
          ]),
        ),
      ]),
    );
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

class _Stat extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _Stat({required this.label, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E22))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 8, letterSpacing: 1.0, fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: -0.5)),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(unit, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF7A7A85))),
          ]
        ]),
      ]),
    );
  }
}

class _Record extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Record({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E22))),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF7A7A85)))),
        Text(value, style: GoogleFonts.inter(fontSize: 14,
            fontWeight: FontWeight.w500, color: Colors.white)),
      ]),
    );
  }
}
