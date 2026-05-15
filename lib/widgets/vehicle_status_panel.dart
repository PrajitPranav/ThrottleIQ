// vehicle_status_panel.dart — Clean diagnostic list.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleStatusPanel extends StatelessWidget {
  const VehicleStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIAGNOSTICS',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: const Color(0xFF5A5A64),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E22)),
            ),
            child: const Column(
              children: [
                _StatusRow(label: 'Powertrain',   status: 'Nominal', isOk: true),
                _Divider(),
                _StatusRow(label: 'Tire Pressure',status: 'Nominal', isOk: true),
                _Divider(),
                _StatusRow(label: 'Oil Temp',     status: '104°C',   isOk: true),
                _Divider(),
                _StatusRow(label: 'Aero Dynamics',status: 'Active',  isOk: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final bool   isOk;

  const _StatusRow({required this.label, required this.status, required this.isOk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOk ? const Color(0xFF5A7D65) : const Color(0xFF8F3232),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF8A8A94),
                ),
              ),
            ),
          ),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isOk ? Colors.white : const Color(0xFF8F3232),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: Color(0xFF18181C), height: 1),
    );
  }
}
