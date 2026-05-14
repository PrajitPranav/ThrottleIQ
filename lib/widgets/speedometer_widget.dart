// speedometer_widget.dart
// Single AnimationController drives ALL needle motion.
// _animatable: Animatable<double> — swapped between TweenSequence (boot) and Tween.chain (demo).
// currentSpeed getter is the one and only source of truth for needle position.

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'demo_control_button.dart';
import 'gauge_painter.dart';
import 'needle_painter.dart';

enum _Phase { boot, idle, demo }

class SpeedometerWidget extends StatefulWidget {
  const SpeedometerWidget({super.key});
  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {

  // ── Single controller ────────────────────────────────────────────────────
  late AnimationController _ctrl;
  // Swapped per phase: TweenSequence (boot) or Tween.chain (demo/idle)
  late Animatable<double> _anim;

  // ── State ────────────────────────────────────────────────────────────────
  _Phase _phase       = _Phase.boot;
  double _targetSpeed = 0;
  Timer? _demoTimer;
  int    _demoIndex   = 0;

  // The single source of truth for what the needle/display shows
  double get _speed => _anim.transform(_ctrl.value).clamp(0.0, 300.0);

  static const List<double> _seq = [
    0, 18, 38, 60, 85, 110, 135, 158, 178,
    198, 218, 242, 265, 278, 284, 278, 265,
    245, 220, 192, 160, 128, 96, 66, 40, 18, 4, 0,
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _anim = Tween<double>(begin: 0, end: 0);
    _ctrl = AnimationController(vsync: this)
      ..addListener(() { if (mounted) setState(() {}); })
      ..addStatusListener(_onStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && _phase == _Phase.boot) {
      setState(() {
        _phase = _Phase.idle;
        _anim  = Tween<double>(begin: 0, end: 0);
        _ctrl.value = 1.0;
      });
    }
  }

  // ── Boot sequence ────────────────────────────────────────────────────────
  // 0 → 300 (easeInCubic, 40% of time) → 0 (easeOutQuint, 60% of time)
  void _boot() {
    if (!mounted) return;
    _ctrl.stop();
    _ctrl.duration = const Duration(milliseconds: 3400);
    _anim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 300.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 300.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutQuint)),
        weight: 60,
      ),
    ]);
    _ctrl.forward(from: 0);
  }

  // ── Smooth needle transition ─────────────────────────────────────────────
  void _animateTo(double target) {
    final double from  = _speed;
    final double delta = (target - from).abs();
    final int    ms    = (delta / 300 * 1400 + 200).round().clamp(200, 1400);

    _ctrl.stop();
    _ctrl.duration = Duration(milliseconds: ms);
    _anim = Tween<double>(begin: from, end: target)
        .chain(CurveTween(curve: Curves.easeInOutCubic));
    _ctrl.forward(from: 0);
    _targetSpeed = target;
  }

  // ── Demo control ─────────────────────────────────────────────────────────
  void _startDemo() {
    if (_phase == _Phase.demo) return;
    _ctrl.stop();
    setState(() { _phase = _Phase.demo; _demoIndex = 0; });
    _animateTo(_seq[0]);
    _demoTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      _demoIndex++;
      if (_demoIndex >= _seq.length) { _stopDemo(); return; }
      _animateTo(_seq[_demoIndex]);
    });
  }

  void _stopDemo() {
    _demoTimer?.cancel(); _demoTimer = null;
    setState(() { _phase = _Phase.idle; _demoIndex = 0; });
    _animateTo(0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _demoTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double spd        = _speed;
    final bool   isDemo     = _phase == _Phase.demo;
    final bool   isBooting  = _phase == _Phase.boot;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statusRow(isDemo, isBooting),
        const SizedBox(height: 18),
        _gaugeStack(spd),
        const SizedBox(height: 24),
        _infoRow(spd),
        const SizedBox(height: 26),
        _buttons(isDemo, isBooting),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statusRow(bool isDemo, bool isBooting) {
    final String txt = isBooting ? 'SYSTEM INITIALIZING'
        : isDemo ? 'SIMULATION RUNNING' : 'SYSTEM STANDBY';
    final Color  c   = isBooting ? AppColors.driveModeComfort
        : isDemo ? AppColors.statusActive : AppColors.statusIdle;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: c,
            boxShadow: (isDemo || isBooting)
                ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8)]
                : [],
          ),
        ),
        const SizedBox(width: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 2.8, color: c),
          child: Text(txt),
        ),
      ],
    );
  }

  Widget _gaugeStack(double spd) {
    return LayoutBuilder(builder: (ctx, con) {
      final double sz = (con.maxWidth * 0.90).clamp(220.0, 390.0);
      return Center(
        child: SizedBox(
          width: sz, height: sz,
          child: Stack(alignment: Alignment.center, children: [
            RepaintBoundary(child: CustomPaint(
              size: Size(sz, sz), painter: GaugePainter(speed: spd))),
            RepaintBoundary(child: CustomPaint(
              size: Size(sz, sz), painter: NeedlePainter(speed: spd))),
            _centerDisplay(spd),
          ]),
        ),
      );
    });
  }

  Widget _centerDisplay(double spd) {
    final String mode = _driveMode(spd);
    final Color  mc   = _modeColor(spd);
    return Transform.translate(
      offset: const Offset(0, 50),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(spd.round().toString().padLeft(3, '0'),
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w200,
              color: AppColors.speedDigit, letterSpacing: -2.0, height: 1.0)),
        const SizedBox(height: 1),
        const Text('KM/H', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
            letterSpacing: 4.5, color: AppColors.speedUnit)),
        const SizedBox(height: 7),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800,
              letterSpacing: 3.5, color: mc),
          child: Text('— $mode —'),
        ),
      ]),
    );
  }

  Widget _infoRow(double spd) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _chip('PEAK', '${_seq.reduce((a, b) => a > b ? a : b).round()} KM/H'),
      _divider(),
      _chip('TARGET', '${_targetSpeed.round()} KM/H'),
      _divider(),
      _chip('MODE', _driveMode(spd)),
    ]);
  }

  Widget _chip(String label, String value) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700,
        letterSpacing: 2, color: AppColors.speedUnit)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.speedDigit, letterSpacing: 0.4)),
  ]);

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18),
    width: 1, height: 22, color: AppColors.btnInactiveBorder);

  Widget _buttons(bool isDemo, bool isBooting) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 44),
    child: Row(children: [
      Expanded(child: DemoControlButton(
        label: 'START', icon: Icons.play_arrow_rounded,
        isActive: !isDemo && !isBooting,
        activeColor: AppColors.btnActiveBorder,
        onPressed: (isDemo || isBooting) ? null : _startDemo,
      )),
      const SizedBox(width: 14),
      Expanded(child: DemoControlButton(
        label: 'STOP', icon: Icons.stop_rounded,
        isActive: isDemo, activeColor: const Color(0xFF404050),
        onPressed: isDemo ? _stopDemo : null,
      )),
    ]),
  );

  String _driveMode(double s) {
    if (s < 80) return 'COMFORT';
    if (s < 160) return 'SPORT';
    if (s < 250) return 'SPORT+';
    return 'TRACK';
  }

  Color _modeColor(double s) {
    if (s < 80) return AppColors.driveModeComfort;
    if (s < 160) return AppColors.driveModeSport;
    return AppColors.driveMode;
  }
}
