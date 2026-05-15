// profile_screen.dart — Premium minimal driver profile.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/settings_service.dart';
import '../../services/profile_service.dart';
import '../../services/trip_storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([SettingsService(), ProfileService(), TripStorageService()]),
      builder: (context, _) {
        final profile = ProfileService();
        final settings = SettingsService();
        final trips = TripStorageService().trips;

        final int totalTrips = trips.length;
        final double totalDistKm = trips.fold(0.0, (sum, t) => sum + t.distanceKm);
        final String distStr = "${settings.formatDistance(totalDistKm)} ${settings.distanceUnit}";
        
        final int totalMinutes = trips.fold(0, (sum, t) => sum + t.durationMinutes);
        final String timeStr = "${(totalMinutes / 60).toStringAsFixed(1)} HR";

        // Dynamic XP Logic: 10 XP per KM
        final double totalXp = totalDistKm * 10;
        final int currentLevel = (totalXp / 5000).floor() + 1;
        final double progressInLevel = (totalXp % 5000) / 5000;
        final String xpStatus = "${(totalXp % 5000).round()} / 5000 XP";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            const SizedBox(height: 32),
            _avatarSection(context, profile, currentLevel),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _xpSection(currentLevel, xpStatus, progressInLevel),
            ),
            const SizedBox(height: 32),
            _header('DRIVER STATS'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _StatChip('TOTAL TRIPS',    totalTrips.toString(), Icons.route_rounded,        const Color(0xFF4F6B8F)),
                const SizedBox(width: 12),
                _StatChip('TOTAL DIST',     distStr,               Icons.map_outlined,         const Color(0xFF5A7D65)),
                const SizedBox(width: 12),
                _StatChip('DRIVE TIME',     timeStr,               Icons.timer_rounded,        const Color(0xFF9E653F)),
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
              child: Column(children: [
                const _LbRow(rank: 1,  name: 'PHANTOM',  score: '98', rankColor: Color(0xFFD4AF37)),
                const _LbRow(rank: 2,  name: 'STEALTH',  score: '96', rankColor: Color(0xFF9E9E9E)),
                const _LbRow(rank: 3,  name: 'APEX',     score: '94', rankColor: Color(0xFFCD7F32)),
                _LbRow(rank: 14, name: profile.userName.toUpperCase(), score: '87', rankColor: const Color(0xFF4F6B8F), isYou: true),
              ]),
            ),

            const SizedBox(height: 36),
            _header('SETTINGS'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                const _SettingsTile(title: 'Theme Selection', icon: Icons.palette_rounded, value: 'Graphite'),
                _SettingsTile(
                  title: 'Units', 
                  icon: Icons.straighten_rounded, 
                  value: settings.speedUnit,
                  onTap: () => _showUnitsDialog(context, settings),
                ),
                _SettingsTile(
                  title: 'Edit Profile', 
                  icon: Icons.person_rounded,
                  onTap: () => _showEditProfileDialog(context, profile),
                ),
                _SettingsTile(
                  title: 'Notifications', 
                  icon: Icons.notifications_rounded,
                  value: settings.notificationsEnabled ? 'ON' : 'OFF',
                  onTap: () => settings.setNotificationsEnabled(!settings.notificationsEnabled),
                ),
                _SettingsTile(
                  title: 'About App', 
                  icon: Icons.info_outline_rounded,
                  onTap: () => _showAboutDialog(context),
                ),
                _SettingsTile(
                  title: 'Contact Us', 
                  icon: Icons.support_agent_rounded,
                  onTap: () => _showContactUsDialog(context),
                ),
                const _SettingsTile(title: 'App Version', icon: Icons.build_rounded, value: 'v2.1.0'),
                const _SettingsTile(title: 'Privacy Policy', icon: Icons.privacy_tip_rounded),
                _SettingsTile(
                  title: 'Terms & Conditions', 
                  icon: Icons.description_rounded,
                  onTap: () => _showTermsDialog(context),
                ),
              ]),
            ),

            const SizedBox(height: 40),
          ]),
        );
      }
    );
  }

  static const _achievements = [
    ('Night Rider',    Icons.nights_stay_rounded,    Color(0xFF4F6B8F),  '10+ night sessions'),
    ('Smooth Driver',  Icons.gesture_rounded,        Color(0xFF5A7D65),  'Avg smoothness > 80%'),
    ('Highway King',   Icons.straight_rounded,       Color(0xFF9E653F),  '2,000+ KM on highways'),
    ('Apex Hunter',    Icons.gps_fixed_rounded,      Color(0xFF8F3232),  'Track mode activated 5x'),
    ('Early Bird',     Icons.wb_sunny_rounded,       Color(0xFF9E653F),  '5 drives before 7 AM'),
    ('Iron Grip',      Icons.speed_rounded,          Color(0xFF4F6B8F),  'Maintained 60+ trips'),
  ];

  Widget _avatarSection(BuildContext context, ProfileService profile, int level) {
    return Column(children: [
      GestureDetector(
        onTap: () => _pickImage(profile),
        child: Container(width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            color: const Color(0xFF1A1A20),
            image: profile.avatarPath != null 
              ? DecorationImage(image: FileImage(File(profile.avatarPath!)), fit: BoxFit.cover)
              : null,
          ),
          child: profile.avatarPath == null ? Center(child: Text(
            profile.userName.isNotEmpty ? profile.userName.substring(0, 1).toUpperCase() : '?', 
            style: GoogleFonts.inter(
              fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: -1.0))) : null,
        ),
      ),
      const SizedBox(height: 16),
      Text(profile.userName, style: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: -0.5,
          color: Colors.white)),
      const SizedBox(height: 6),
      Text('LVL $level  •  ${_getRankTitle(level)}',
        style: GoogleFonts.inter(fontSize: 9, letterSpacing: 1.5,
            fontWeight: FontWeight.w600, color: const Color(0xFF5A5A64))),
    ]);
  }

  String _getRankTitle(int level) {
    if (level > 20) return 'LEGENDARY DRIVER';
    if (level > 10) return 'EXPERT DRIVER';
    if (level > 5) return 'SKILLED DRIVER';
    return 'NOVICE DRIVER';
  }

  Future<void> _pickImage(ProfileService profile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profile.updateAvatar(pickedFile.path);
    }
  }

  void _showUnitsDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('SELECT UNITS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Metric (KM/H, KM)'),
              onTap: () { settings.setUseMetric(true); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('Imperial (MPH, MI)'),
              onTap: () { settings.setUseMetric(false); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileService profile) {
    final controller = TextEditingController(text: profile.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('EDIT PROFILE', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(color: Color(0xFF5A5A64)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E1E22))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () { profile.updateName(controller.text); Navigator.pop(ctx); },
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('ABOUT THROTTLEIQ', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text(
          'ThrottleIQ is a premium automotive telemetry platform designed for enthusiasts who demand precision. Track your speed, route, and performance metrics in real-time with our German-engineered interface.\n\nBuilt for the road. Refined for the track.',
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A94), height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showContactUsDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final queryCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('CONTACT US', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: Color(0xFF5A5A64))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: queryCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Your Query', labelStyle: TextStyle(color: Color(0xFF5A5A64))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Query submitted successfully!')));
              Navigator.pop(ctx);
            },
            child: const Text('SUBMIT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101014),
        title: Text('TERMS & CONDITIONS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        content: SingleChildScrollView(
          child: Text(
            '1. Drive Safely: ThrottleIQ is for information purposes only. Do not use the app while driving.\n\n'
            '2. Data Accuracy: GPS telemetry can vary based on hardware and satellite availability.\n\n'
            '3. Privacy: Your trip data is stored locally on your device.\n\n'
            '4. Responsibility: The user assumes all risk and liability for their driving behavior.\n\n'
            '5. Updates: We reserve the right to modify features to improve performance.',
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A8A94), height: 1.6),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('AGREE', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _xpSection(int level, String status, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E22))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LEVEL $level', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
              letterSpacing: 2.0, color: Colors.white)),
          Text(status, style: GoogleFonts.inter(fontSize: 9,
              color: const Color(0xFF7A7A85))),
        ]),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
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
  final VoidCallback? onTap;

  const _SettingsTile({required this.title, required this.icon, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
