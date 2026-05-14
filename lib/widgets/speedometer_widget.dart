// speedometer_widget.dart — Premium analog speedometer dashboard widget.
//
// ARCHITECTURE OVERVIEW
// ─────────────────────
// The widget uses two separate animation systems:
//
//   1. _bootController  → fires once on startup, sweeps the needle from 0→240→0
//                         to simulate a real car cluster "ignition boot" animation.
//
//   2. _needleController → drives ongoing smooth needle movement.
//                          When the target speed changes, we Tween from the
//                          current animated value to the new target.
//                          This produces fluid, weighted, mechanical motion.
//
// Demo speed simulation:
//   A Timer fires every 2 seconds and advances through the speed sequence.
//   Rather than jumping instantly, the needle glides to the new target via
//   a CurvedAnimation with a custom easeInOutCubic feel.
//
// Rendering:
//   • GaugePainter  → draws the static gauge face (repaints with speed for glow)
//   • NeedlePainter → draws the needle every animation frame
//   • Annotation    → the center digital display (speed number + KM/H + mode)

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'demo_control_button.dart';
import 'gauge_painter.dart';
import 'needle_painter.dart';

class SpeedometerWidget extends StatefulWidget {
  const SpeedometerWidget({super.key});

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with TickerProviderStateMixin {

  // ─── ANIMATION CONTROLLERS ───────────────────────────────────────────────────

  // Boot sweep animation (runs once on initState)
  late final AnimationController _bootController;
  late final Animation<double>    _bootAnimation;

  // Needle value animation (drives ongoing smooth needle movement)
  late final AnimationController _needleController;
  late Animation<double>         _needleAnimation;

  // ─── SPEED STATE ─────────────────────────────────────────────────────────────

  // The "visual" speed shown on needle — driven purely by _needleAnimation
  double _displaySpeed = 0;

  // The target speed we want the needle to reach
  double _targetSpeed = 0;

  // ─── DEMO STATE ──────────────────────────────────────────────────────────────

  bool   _isDemoRunning = false;
  Timer? _demoTimer;
  int    _demoIndex     = 0;

  // Speed sequence for the demo.
  // Designed to feel like real acceleration → cruise → deceleration.
  // Steps are close together for realistic incremental movement.
  final List<double> _demoSpeeds = [
    0, 15, 30, 48, 65, 82, 100, 118, 135, 150,
    162, 175, 185, 192, 198, 202, 198, 188, 170,
    150, 125, 100, 75, 55, 38, 22, 10, 0,
  ];

  // Drive mode labels that change with speed ranges
  String get _driveMode {
    if (_displaySpeed < 60)  return 'ECO';
    if (_displaySpeed < 120) return 'COMFORT';
    if (_displaySpeed < 180) return 'SPORT';
    return 'SPORT+';
  }

  // ─── LIFECYCLE ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runBootSequence();
  }

  void _initAnimations() {
    // Boot sweep: full 0→240→0 in 3 seconds
    _bootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Ease: fast rise to 240, then slow graceful return to 0
    _bootAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 240.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 240.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 55,
      ),
    ]).animate(_bootController)
      ..addListener(() {
        if (mounted && !_isDemoRunning) {
          setState(() => _displaySpeed = _bootAnimation.value);
        }
      });

    // Needle animation controller — we drive it manually per target change
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initial animation stays at 0
    _needleAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _needleController, curve: Curves.easeInOutCubic),
    )..addListener(() {
      if (mounted) setState(() => _displaySpeed = _needleAnimation.value);
    });
  }

  // The boot sequence runs on app launch — mimics a real car cluster sweep
  void _runBootSequence() {
    _bootController.forward().then((_) {
      // After the boot sweep, snap display speed to 0
      if (mounted) setState(() => _displaySpeed = 0);
    });
  }

  // ─── SPEED ANIMATION ─────────────────────────────────────────────────────────

  /// Smoothly animates the needle from its current visual position to [newSpeed].
  /// Uses a weighted duration so large jumps animate proportionally longer.
  void _animateTo(double newSpeed) {
    final double from = _displaySpeed;
    final double delta = (newSpeed - from).abs();

    // Duration scales with how far the needle has to travel (60–1200ms range)
    // This makes fast jumps feel rapid and slow ones feel controlled.
    final int durationMs = (delta / 240 * 1400 + 200).round().clamp(200, 1400);

    _needleController.stop();
    _needleController.duration = Duration(milliseconds: durationMs);

    _needleAnimation = Tween<double>(begin: from, end: newSpeed).animate(
      CurvedAnimation(parent: _needleController, curve: Curves.easeInOutCubic),
    )..addListener(() {
      if (mounted) setState(() => _displaySpeed = _needleAnimation.value);
    });

    _needleController.forward(from: 0);
    _targetSpeed = newSpeed;
  }

  // ─── DEMO CONTROL ────────────────────────────────────────────────────────────

  void _startDemo() {
    if (_isDemoRunning) return;

    // Cancel boot animation if still playing
    _bootController.stop();

    setState(() {
      _isDemoRunning = true;
      _demoIndex     = 0;
    });

    // Animate to first target immediately
    _animateTo(_demoSpeeds[_demoIndex]);

    // Each step fires every 1.8 seconds — matches the animation duration range
    _demoTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      _demoIndex++;
      if (_demoIndex >= _demoSpeeds.length) {
        _stopDemo();
        return;
      }
      _animateTo(_demoSpeeds[_demoIndex]);
    });
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;

    setState(() {
      _isDemoRunning = false;
      _demoIndex     = 0;
    });

    _animateTo(0); // Glide needle back to zero
  }

  @override
  void dispose() {
    _bootController.dispose();
    _needleController.dispose();
    _demoTimer?.cancel();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusRow(),
        const SizedBox(height: 20),
        _buildGaugeStack(),
        const SizedBox(height: 28),
        _buildInfoRow(),
        const SizedBox(height: 28),
        _buildControlButtons(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── STATUS ROW ──────────────────────────────────────────────────────────────

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glowing indicator dot
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isDemoRunning
                ? AppColors.statusActive
                : AppColors.statusIdle,
            boxShadow: _isDemoRunning
                ? [BoxShadow(
                    color: AppColors.glowRed,
                    blurRadius: 10,
                    spreadRadius: 3,
                  )]
                : [],
          ),
        ),
        const SizedBox(width: 9),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            color: _isDemoRunning
                ? AppColors.statusActive
                : AppColors.statusIdle,
          ),
          child: Text(_isDemoRunning ? 'SIMULATION RUNNING' : 'SYSTEM STANDBY'),
        ),
      ],
    );
  }

  // ─── GAUGE STACK ─────────────────────────────────────────────────────────────

  Widget _buildGaugeStack() {
    return LayoutBuilder(builder: (context, constraints) {
      // Gauge size: the smaller of 88% screen width or 380dp
      final double gaugeSize = (constraints.maxWidth * 0.88).clamp(200.0, 380.0);

      return Center(
        child: SizedBox(
          width:  gaugeSize,
          height: gaugeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Layer 1: Gauge face (background, bezel, arcs, ticks, labels)
              // Repaint only when speed changes (for glow color update)
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(gaugeSize, gaugeSize),
                  painter: GaugePainter(speed: _displaySpeed),
                ),
              ),

              // Layer 2: Needle — repaints every animation frame
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(gaugeSize, gaugeSize),
                  painter: NeedlePainter(speed: _displaySpeed),
                ),
              ),

              // Layer 3: Center digital display
              _buildCenterDisplay(),
            ],
          ),
        ),
      );
    });
  }

  // ─── CENTER DIGITAL DISPLAY ──────────────────────────────────────────────────

  Widget _buildCenterDisplay() {
    // Shift the display slightly below center so it sits naturally
    // below the needle pivot in the "data zone" of the dial
    return Transform.translate(
      offset: const Offset(0, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large speed number
          Text(
            _displaySpeed.round().toString().padLeft(3, '0'),
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w300,
              color: AppColors.speedDigit,
              letterSpacing: -1.0,
              height: 1.0,
              fontFamily: 'RobotoMono',
            ),
          ),

          const SizedBox(height: 2),

          // KM/H unit label
          const Text(
            'KM/H',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: AppColors.speedUnit,
            ),
          ),

          const SizedBox(height: 8),

          // Drive mode badge — changes color and label with speed
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 600),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
              color: _displaySpeed >= 120
                  ? AppColors.driveMode
                  : AppColors.speedUnit.withValues(alpha: 0.7),
            ),
            child: Text('— $_driveMode —'),
          ),
        ],
      ),
    );
  }

  // ─── INFO ROW ────────────────────────────────────────────────────────────────

  Widget _buildInfoRow() {
    // Small stat chips below the gauge — max speed reached and avg
    // (static for now, will be populated from real data later)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInfoChip('MAX', '${_demoSpeeds.reduce((a, b) => a > b ? a : b).round()} KM/H'),
        const SizedBox(width: 24),
        _buildInfoChip('TARGET', '${_targetSpeed.round()} KM/H'),
        const SizedBox(width: 24),
        _buildInfoChip('MODE', _driveMode),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.speedUnit,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.speedDigit,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── CONTROL BUTTONS ─────────────────────────────────────────────────────────

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Row(
        children: [
          Expanded(
            child: DemoControlButton(
              label: 'START',
              icon: Icons.play_arrow_rounded,
              isActive: !_isDemoRunning,
              activeColor: AppColors.btnActiveBorder,
              onPressed: _isDemoRunning ? null : _startDemo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DemoControlButton(
              label: 'STOP',
              icon: Icons.stop_rounded,
              isActive: _isDemoRunning,
              activeColor: const Color(0xFF444455),
              onPressed: _isDemoRunning ? _stopDemo : null,
            ),
          ),
        ],
      ),
    );
  }
}
