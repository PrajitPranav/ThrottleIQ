// garage_screen.dart — Premium vehicle showcase.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _vehicleCard()),
        const SizedBox(height: 24),
        _header('VEHICLE STATS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, childAspectRatio: 2.0,
            crossAxisSpacing: 10, mainAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _stat('ODOMETER',  '12,847',  'KM',       Icons.speed_rounded,         const Color(0xFF4A9ECC), 0),
              _stat('TOP SPEED', '284',      'KM/H',     Icons.north_rounded,         const Color(0xFFCC1800), 80),
              _stat('SESSIONS',  '47',       'TRIPS',    Icons.route_rounded,         const Color(0xFF26A65B), 160),
              _stat('FAV MODE',  'SPORT+',   '',         Icons.tune_rounded,          const Color(0xFFE08020), 240),
              _stat('AVG SCORE', '87',       '/ 100',    Icons.star_rounded,          const Color(0xFF26A65B), 320),
              _stat('BEST LAP',  '01:42.3',  'MM:SS',    Icons.timer_rounded,         const Color(0xFF4A9ECC), 400),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _header('SESSION RECORDS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _record('Longest Trip',     '1 hr 14 min', Icons.schedule_rounded,     const Color(0xFF4A9ECC), 0),
            _record('Highest G-Force',  '1.42 G',      Icons.compress_rounded,     const Color(0xFFCC1800), 80),
            _record('Night Sessions',   '18 drives',   Icons.nights_stay_rounded,  const Color(0xFFE08020), 160),
            _record('Highway Distance', '2,140 KM',    Icons.straight_rounded,     const Color(0xFF26A65B), 240),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _vehicleCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF111118), Color(0xFF0A0A0F)],
        ),
        border: Border.all(color: const Color(0xFF1E1E28)),
        boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(height: 200, child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/one.png', fit: BoxFit.cover,
              errorBuilder: (ctx, obj, e) => Container(
                color: const Color(0xFF0D0D14),
                child: const Center(child: Icon(Icons.directions_car_rounded,
                    size: 80, color: Color(0xFF1A1A22))))),
            const DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC0A0A0F)], stops: [0.4, 1.0]))),
            Positioned(top: 14, right: 14, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0x99CC1800),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0x80CC1800))),
              child: Text('SPORT+', style: GoogleFonts.exo2(
                  fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.white)),
            )),
          ])),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('PANAMERA GTS', style: GoogleFonts.rajdhani(
                  fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2.0,
                  color: Colors.white.withValues(alpha: 0.95)))),
              Text('2024', style: GoogleFonts.exo2(
                  fontSize: 11, color: const Color(0xFF3A3A4A), letterSpacing: 1.5)),
            ]),
            const SizedBox(height: 2),
            Text('"GHOST"  •  Night Black Metallic', style: GoogleFonts.exo2(
                fontSize: 9, letterSpacing: 1.2, color: const Color(0xFF3A3A4A))),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _stat(String label, String value, String unit,
      IconData icon, Color color, int delay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Row(children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: GoogleFonts.exo2(fontSize: 7, letterSpacing: 1.5,
              color: const Color(0xFF3A3A4A))),
          const SizedBox(height: 2),
          RichText(text: TextSpan(children: [
            TextSpan(text: value, style: GoogleFonts.rajdhani(fontSize: 17,
                fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
            if (unit.isNotEmpty)
              TextSpan(text: ' $unit', style: GoogleFonts.exo2(
                  fontSize: 7, color: color.withValues(alpha: 0.6))),
          ])),
        ])),
      ]),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms);
  }

  Widget _record(String label, String value, IconData icon, Color color, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A1A22))),
      child: Row(children: [
        Icon(icon, size: 15, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.exo2(
            fontSize: 10, letterSpacing: 1.0, color: const Color(0xFF4A4A5A)))),
        Text(value, style: GoogleFonts.rajdhani(fontSize: 15,
            fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
      ]),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: 0.04, end: 0);
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Text(text, style: GoogleFonts.exo2(fontSize: 8, fontWeight: FontWeight.w700,
          letterSpacing: 3.0, color: const Color(0xFF3A3A4A))),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Color(0xFF1A1A22), height: 1)),
    ]),
  );
}
