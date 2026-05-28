import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedDistributionWidget extends StatelessWidget {
  final List<double> samples;

  const SpeedDistributionWidget({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) return const SizedBox.shrink();

    int range1 = 0; // < 70
    int range2 = 0; // 70-140
    int range3 = 0; // 140-210
    int range4 = 0; // > 210

    for (var s in samples) {
      if (s < 70)        { range1++; }
      else if (s < 140)  { range2++; }
      else if (s < 210)  { range3++; }
      else               { range4++; }
    }

    final total = samples.length;
    final p1 = (range1 / total);
    final p2 = (range2 / total);
    final p3 = (range3 / total);
    final p4 = (range4 / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPEED DISTRIBUTION',
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: const Color(0xFF5A5A64),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFF101014),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (p1 > 0) Expanded(flex: (p1 * 1000).toInt(), child: Container(color: const Color(0xFF4F6B8F))),
                if (p2 > 0) Expanded(flex: (p2 * 1000).toInt(), child: Container(color: const Color(0xFF5A7D65))),
                if (p3 > 0) Expanded(flex: (p3 * 1000).toInt(), child: Container(color: const Color(0xFF9E653F))),
                if (p4 > 0) Expanded(flex: (p4 * 1000).toInt(), child: Container(color: const Color(0xFF8F3232))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _LegendRow(
          items: [
            _LegendItem(label: '< 70', percentage: (p1 * 100).round(), color: const Color(0xFF4F6B8F)),
            _LegendItem(label: '70-140', percentage: (p2 * 100).round(), color: const Color(0xFF5A7D65)),
            _LegendItem(label: '140-210', percentage: (p3 * 100).round(), color: const Color(0xFF9E653F)),
            _LegendItem(label: '> 210', percentage: (p4 * 100).round(), color: const Color(0xFF8F3232)),
          ],
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final List<_LegendItem> items;
  const _LegendRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.where((i) => i.percentage > 0).toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _LegendItem({required this.label, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(
          '$label KM/H',
          style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF8A8A94), fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        Text(
          '$percentage%',
          style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
