// profile_screen.dart — Premium minimal driver profile.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _achievements = [
    ('Night Rider',    Icons.nights_stay_rounded,    Color(0xFF4F6B8F),  '10+ night sessions'),
    ('Smooth Driver',  Icons.gesture_rounded,        Color(0xFF5A7D65),  'Avg smoothness > 80%'),
    ('Highway King',   Icons.straight_rounded,       Color(0xFF9E653F),  '2,000+ KM on highways'),
    ('Apex Hunter',    Icons.gps_fixed_rounded,      Color(0xFF8F3232),  'Track mode activated 5x'),
    ('Early Bird',     Icons.wb_sunny_rounded,       Color(0xFF9E653F),  '5 drives before 7 AM'),
    ('Iron Grip',      Icons.speed_rounded,          Color(0xFF4F6B8F),  'Maintained 60+ trips'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 32),
        _avatarSection(),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _xpSection(),
        ),
        const SizedBox(height: 32),
        _header('DRIVER STATS'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: const [
            _StatChip('TOTAL TRIPS',    '47',        Icons.route_rounded,        Color(0xFF4F6B8F)),
            SizedBox(width: 12),
            _StatChip('TOTAL DIST',     '1,842 KM',  Icons.map_outlined,         Color(0xFF5A7D65)),
            SizedBox(width: 12),
            _StatChip('DRIVE TIME',     '62 HR',     Icons.timer_rounded,        Color(0xFF9E653F)),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: const [
            _StatChip('STREAK',         '7 DAYS',    Icons.local_fire_department, Color(0xFF8F3232)),
            SizedBox(width: 12),
            _StatChip('BEST SCORE',     '98 / 100',  Icons.star_rounded,         Color(0xFF5A7D65)),
            SizedBox(width: 12),
            _StatChip('RANK',           '#14',       Icons.leaderboard_rounded,  Color(0xFF4F6B8F)),
          ]),
        ),

        const SizedBox(height: 36),
        _header('ACHIEVEMENTS'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, childAspectRatio: 2.2,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(_achievements.length, (i) {
              final a = _achievements[i];
              return _Badge(title: a.$1, icon: a.$2, color: a.$3, sub: a.$4);
            }),
          ),
        ),

        const SizedBox(height: 36),
        _header('LOCAL LEADERBOARD'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: const [
            _LbRow(rank: 1,  name: 'PHANTOM',  score: '98', rankColor: Color(0xFFD4AF37)),
            _LbRow(rank: 2,  name: 'STEALTH',  score: '96', rankColor: Color(0xFF9E9E9E)),
            _LbRow(rank: 3,  name: 'APEX',     score: '94', rankColor: Color(0xFFCD7F32)),
            _LbRow(rank: 14, name: 'YOU',      score: '87', rankColor: Color(0xFF4F6B8F), isYou: true),
          ]),
        ),

        const SizedBox(height: 36),
        _header('SETTINGS'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: const [
            _SettingsTile(title: 'Theme Selection', icon: Icons.palette_rounded, value: 'Graphite'),
            _SettingsTile(title: 'Units', icon: Icons.straighten_rounded, value: 'KM/H'),
            _SettingsTile(title: 'Edit Profile', icon: Icons.person_rounded),
            _SettingsTile(title: 'Notifications', icon: Icons.notifications_rounded),
            _SettingsTile(title: 'About App', icon: Icons.info_outline_rounded),
            _SettingsTile(title: 'Contact Us', icon: Icons.support_agent_rounded),
            _SettingsTile(title: 'App Version', icon: Icons.build_rounded, value: 'v2.1.0'),
            _SettingsTile(title: 'Privacy Policy', icon: Icons.privacy_tip_rounded),
            _SettingsTile(title: 'Terms & Conditions', icon: Icons.description_rounded),
          ]),
        ),

        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _avatarSection() {
    return Column(children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A1A20)),
        child: Center(child: Text('PJ', style: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: -1.0))),
      ),
      const SizedBox(height: 16),
      Text('Prajit Pranav', style: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: -0.5,
          color: Colors.white)),
      const SizedBox(height: 6),
      Text('LVL 7  •  EXPERT DRIVER',
        style: GoogleFonts.inter(fontSize: 9, letterSpacing: 1.5,
            fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
    ]);
  }

  Widget _xpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E22))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LEVEL 7', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
              letterSpacing: 2.0, color: Colors.white)),
          Text('3,420 / 5,000 XP', style: GoogleFonts.inter(fontSize: 9,
              color: const Color(0xFF7A7A85))),
        ]),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 0.684),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (ctx, v, child) => ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: v, minHeight: 4,
              backgroundColor: const Color(0xFF1E1E22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
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

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF101014),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E1E22))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 14,
              fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 8, letterSpacing: 1.0,
              fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String title, sub;
  final IconData icon;
  final Color color;
  const _Badge({required this.title, required this.icon, required this.color, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E22))),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 11,
              fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF7A7A85))),
        ])),
      ]),
    );
  }
}

class _LbRow extends StatelessWidget {
  final int rank;
  final String name, score;
  final Color rankColor;
  final bool isYou;
  const _LbRow({required this.rank, required this.name, required this.score, required this.rankColor, this.isYou = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFF1E1E24) : const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isYou ? const Color(0xFF2C2C32) : const Color(0xFF1E1E22))),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#$rank', style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, color: rankColor))),
        Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 12,
            fontWeight: FontWeight.w500, color: isYou ? Colors.white : const Color(0xFF7A7A85)))),
        Text(score, style: GoogleFonts.inter(fontSize: 14,
            fontWeight: FontWeight.w500, color: Colors.white)),
        Text(' pts', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5A5A64))),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? value;

  const _SettingsTile({required this.title, required this.icon, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E22))
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF8A8A94)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title, style: GoogleFonts.inter(fontSize: 13, 
            fontWeight: FontWeight.w500, color: Colors.white)),
        ),
        if (value != null) ...[
          Text(value!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7A7A85))),
          const SizedBox(width: 8),
        ],
        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF5A5A64)),
      ]),
    );
  }
}
