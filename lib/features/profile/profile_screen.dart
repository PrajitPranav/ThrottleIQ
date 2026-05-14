// profile_screen.dart — Premium gamified driver profile.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _achievements = [
    ('Night Rider',    Icons.nights_stay_rounded,    Color(0xFF4A9ECC),  'Drove 10+ night sessions'),
    ('Smooth Driver',  Icons.gesture_rounded,        Color(0xFF26A65B),  'Avg smoothness > 80%'),
    ('Highway King',   Icons.straight_rounded,       Color(0xFFE08020),  '2,000+ KM on highways'),
    ('Apex Hunter',    Icons.gps_fixed_rounded,      Color(0xFFCC1800),  'Track mode activated 5x'),
    ('Early Bird',     Icons.wb_sunny_rounded,       Color(0xFFE08020),  '5 drives before 7 AM'),
    ('Iron Grip',      Icons.speed_rounded,          Color(0xFF4A9ECC),  'Maintained 60+ trips'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 24),

        // ── Avatar + rank ─────────────────────────────────────────────────
        _avatarSection(),
        const SizedBox(height: 24),

        // ── XP progress ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _xpSection(),
        ),
        const SizedBox(height: 24),

        // ── Quick stats ───────────────────────────────────────────────────
        _header('DRIVER STATS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            _statChip('TOTAL TRIPS',    '47',        Icons.route_rounded,        const Color(0xFF4A9ECC), 0),
            const SizedBox(width: 10),
            _statChip('TOTAL DIST',     '1,842 KM',  Icons.map_outlined,         const Color(0xFF26A65B), 100),
            const SizedBox(width: 10),
            _statChip('DRIVE TIME',     '62 HR',     Icons.timer_rounded,        const Color(0xFFE08020), 200),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            _statChip('STREAK',         '7 DAYS',    Icons.local_fire_department_rounded, const Color(0xFFCC1800), 0),
            const SizedBox(width: 10),
            _statChip('BEST SCORE',     '98 / 100',  Icons.star_rounded,         const Color(0xFF26A65B), 100),
            const SizedBox(width: 10),
            _statChip('RANK',           '#14',       Icons.leaderboard_rounded,  const Color(0xFF4A9ECC), 200),
          ]),
        ),

        const SizedBox(height: 24),

        // ── Achievements ─────────────────────────────────────────────────
        _header('ACHIEVEMENTS'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, childAspectRatio: 2.2,
            crossAxisSpacing: 10, mainAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(_achievements.length, (i) {
              final a = _achievements[i];
              return _badge(a.$1, a.$2, a.$3, a.$4, i * 80);
            }),
          ),
        ),

        const SizedBox(height: 24),

        // ── Leaderboard preview ───────────────────────────────────────────
        _header('LOCAL LEADERBOARD'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _lbRow(1,  'PHANTOM',  '98', const Color(0xFFFFD700), 0),
            _lbRow(2,  'STEALTH',  '96', const Color(0xFFAAAAAA), 80),
            _lbRow(3,  'APEX',     '94', const Color(0xFFCD7F32), 160),
            _lbRow(14, 'YOU',      '87', const Color(0xFF4A9ECC), 240),
          ]),
        ),

        const SizedBox(height: 28),
      ]),
    );
  }

  Widget _avatarSection() {
    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        Container(width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFCC1800), Color(0xFF660C00)]),
            boxShadow: [BoxShadow(color: const Color(0xFFCC1800).withValues(alpha: 0.4),
                blurRadius: 20, spreadRadius: 2)]),
          child: Center(child: Text('PJ', style: GoogleFonts.rajdhani(
              fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
        ).animate().scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.elasticOut),

        // Rank badge
        Positioned(bottom: 0, right: 0, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF0D0D12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCC1800).withValues(alpha: 0.5))),
          child: Text('LVL 7', style: GoogleFonts.exo2(
              fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.5,
              color: const Color(0xFFCC1800))),
        )),
      ]),
      const SizedBox(height: 12),
      Text('PRAJIT PRANAV', style: GoogleFonts.rajdhani(
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 3.0,
          color: Colors.white.withValues(alpha: 0.95))),
      const SizedBox(height: 3),
      Text('EXPERT DRIVER  •  TRACK SPECIALIST',
        style: GoogleFonts.exo2(fontSize: 8, letterSpacing: 2.0,
            color: const Color(0xFF3A3A4A))),
    ]);
  }

  Widget _xpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A22))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LEVEL 7', style: GoogleFonts.exo2(fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 2.0, color: const Color(0xFFCC1800))),
          Text('3,420 / 5,000 XP', style: GoogleFonts.exo2(fontSize: 9,
              letterSpacing: 1.5, color: const Color(0xFF3A3A4A))),
        ]),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 0.684),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: v, minHeight: 6,
              backgroundColor: const Color(0xFF161620),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCC1800))),
          ),
        ),
        const SizedBox(height: 8),
        Text('1,580 XP to Level 8', style: GoogleFonts.exo2(
            fontSize: 8, color: const Color(0xFF2A2A38))),
      ]),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _statChip(String label, String value, IconData icon, Color color, int delay) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF0D0D12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.rajdhani(fontSize: 14,
              fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.88))),
          Text(label, style: GoogleFonts.exo2(fontSize: 7, letterSpacing: 1.0,
              color: const Color(0xFF3A3A4A))),
        ]),
      ).animate(delay: delay.ms).fadeIn(duration: 400.ms),
    );
  }

  Widget _badge(String title, IconData icon, Color color, String sub, int delay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 10)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: GoogleFonts.rajdhani(fontSize: 13,
              fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.88))),
          Text(sub, style: GoogleFonts.exo2(fontSize: 7, letterSpacing: 0.5,
              color: const Color(0xFF3A3A4A))),
        ])),
      ]),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _lbRow(int rank, String name, String score, Color rankColor, int delay) {
    final bool isYou = name == 'YOU';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFF4A9ECC).withValues(alpha: 0.08) : const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isYou
            ? const Color(0xFF4A9ECC).withValues(alpha: 0.3) : const Color(0xFF1A1A22))),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#$rank', style: GoogleFonts.rajdhani(
            fontSize: 15, fontWeight: FontWeight.w700, color: rankColor))),
        Expanded(child: Text(name, style: GoogleFonts.exo2(fontSize: 11,
            letterSpacing: 1.5, fontWeight: FontWeight.w600,
            color: isYou ? const Color(0xFF4A9ECC) : Colors.white.withValues(alpha: 0.7)))),
        Text(score, style: GoogleFonts.rajdhani(fontSize: 16,
            fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.88))),
        Text(' pts', style: GoogleFonts.exo2(fontSize: 8, color: const Color(0xFF3A3A4A))),
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
