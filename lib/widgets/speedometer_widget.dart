// speedometer_widget.dart — Premium ThrottleIQ analog cluster widget.
//
// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION ARCHITECTURE — READ THIS FIRST
// ═══════════════════════════════════════════════════════════════════════════
//
// Problem with the old approach:
//   Two AnimationControllers (_bootController and _needleController) both
//   wrote to _displaySpeed.  When _needleController initialized its listener
//   it immediately fired with value 0.0 — overwriting the boot sweep value.
//   This is why the ignition animation never worked correctly.
//
// Solution — single-controller state machine:
//   ONE AnimationController (_controller) drives the needle at all times.
//   A _GaugePhase enum tracks what we're doing:
//
//     • _GaugePhase.boot
//         On app launch. TweenSequence animates 0 → 300 → 0.
//         Simulates a Porsche cluster ignition sweep.
//         The user cannot interact during this phase.
//
//     • _GaugePhase.idle
//         After boot completes. Needle sits at 0. Buttons are enabled.
//
//     • _GaugePhase.demo
//         Demo simulation running. Timer fires every 1.6 s, calls
//         _animateTo() to glide the needle to the next speed target.
//
//   _animateTo() always:
//     1. Cancels any in-progress animation on _controller
//     2. Creates a new Tween from current _displaySpeed → newTarget
//     3. Sets a proportional duration (faster for small deltas)
//     4. Starts _controller.forward(from:0)
//
// Rendering — two RepaintBoundary layers:
//   Layer 1: GaugePainter  — gauge face (repaints only when speed zone changes)
//   Layer 2: NeedlePainter — needle (repaints every frame)
//
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'demo_control_button.dart';
import 'gauge_painter.dart';
import 'needle_painter.dart';

// Phase enum — the gauge is always in exactly one of these states
enum _GaugePhase { boot, idle, demo }

class SpeedometerWidget extends StatefulWidget {
  const SpeedometerWidget({super.key});

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {

  // ─── The ONE controller that drives everything ────────────────────────────
  late AnimationController _controller;

  // The Tween changes on every _animateTo() call.
  // We keep it as a field so we can always read the current value.
  late Tween<double> _speedTween;

  // ─── Phase & demo state ───────────────────────────────────────────────────
  _GaugePhase _phase     = _GaugePhase.boot;
  Timer?      _demoTimer;
  int         _demoIndex = 0;
  double      _targetSpeed = 0;

  // Demo speed sequence — realistic acceleration/deceleration profile
  // reaching 280 km/h peak to exercise the full 0-300 scale
  static const List<double> _demoSpeeds = [
    0, 18, 38, 60, 82, 105, 128, 150, 170,
    190, 210, 235, 258, 272, 280, 276, 265,
    248, 225, 198, 170, 140, 108, 78, 50, 25, 8, 0,
  ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Start with a zero-to-zero tween; the boot sequence overwrites it.
    _speedTween = Tween<double>(begin: 0.0, end: 0.0);

    _controller = AnimationController(vsync: this)
      ..addListener(_onAnimationTick)
      ..addStatusListener(_onAnimationStatus);

    // Small delay so the first frame renders before we start sweeping.
    // Without this, the tween has no physical canvas size yet.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBootSequence());
  }

  // Called every animation frame — just triggers a rebuild
  void _onAnimationTick() {
    if (mounted) setState(() {});
  }

  // Called when the controller finishes a forward run
  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _phase == _GaugePhase.boot) {
      // Boot sweep complete → transition to idle
      if (mounted) {
        setState(() {
          _phase = _GaugePhase.idle;
          // Snap tween to 0→0 so _displaySpeed reads as exactly 0
          _speedTween = Tween<double>(begin: 0.0, end: 0.0);
          _controller.value = 1.0; // evaluates to 0.0
        });
      }
    }
  }

  // ─── Ignition Boot Sequence ───────────────────────────────────────────────
  //
  // Phase: boot
  // Animation: 0 → 300 (fast) → 0 (graceful) in ~3.2 seconds.
  // Exactly mirrors a Porsche Taycan cluster startup sweep.

  void _runBootSequence() {
    if (!mounted) return;

    // TweenSequence on a SINGLE controller — no race condition possible
    _speedTween = Tween<double>(begin: 0.0, end: 0.0); // will be overridden
    _controller.stop();
    _controller.duration = const Duration(milliseconds: 3200);

    // We implement the two-segment sweep by animating 0→1 on the controller
    // and using a TweenSequence to map that to 0→300→0.
    final animation = TweenSequence<double>([
      TweenSequenceItem(
        // 0 → 300: easeInCubic (slow start, fast climb — like a real gauge)
        tween: Tween(begin: 0.0, end: 300.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        // 300 → 0: easeOutQuint (fast start, very smooth deceleration)
        tween: Tween(begin: 300.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutQuint)),
        weight: 60,
      ),
    ]).animate(_controller);

    // Override _displaySpeed to use the sequence animation during boot
    _controller.addListener(() {
      if (_phase == _GaugePhase.boot && mounted) {
        // During boot we read from the sequence directly
        _bootDisplaySpeed = animation.value;
        setState(() {});
      }
    });

    _controller.forward(from: 0);
  }

  // Separate boot speed value — avoids the tween evaluation during boot phase
  double _bootDisplaySpeed = 0.0;

  // ─── Speed Getter — the single source of truth ────────────────────────────

  double get currentSpeed {
    if (_phase == _GaugePhase.boot) return _bootDisplaySpeed;
    // For idle and demo: evaluate the tween at the current controller value
    return _speedTween.transform(_controller.value);
  }

  // ─── Needle Animation ─────────────────────────────────────────────────────

  /// Smoothly animate the needle from [currentSpeed] to [newSpeed].
  /// Duration is proportional to the distance (200–1200 ms range).
  void _animateTo(double newSpeed) {
    final double from  = currentSpeed;
    final double delta = (newSpeed - from).abs();
    final int    ms    = (delta / 300 * 1400 + 200).round().clamp(200, 1400);

    _controller.stop();
    _controller.duration = Duration(milliseconds: ms);
    _speedTween = Tween<double>(begin: from, end: newSpeed);
    _controller.forward(from: 0);
    _targetSpeed = newSpeed;
  }

  // ─── Demo Control ─────────────────────────────────────────────────────────

  void _startDemo() {
    if (_phase == _GaugePhase.demo) return;

    _controller.stop();
    setState(() {
      _phase     = _GaugePhase.demo;
      _demoIndex = 0;
    });

    _animateTo(_demoSpeeds[_demoIndex]);

    _demoTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
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
      _phase     = _GaugePhase.idle;
      _demoIndex = 0;
    });
    _animateTo(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _demoTimer?.cancel();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double speed = currentSpeed.clamp(0.0, 300.0);
    final bool   isDemoRunning = _phase == _GaugePhase.demo;
    final bool   isBooting     = _phase == _GaugePhase.boot;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusRow(isDemoRunning, isBooting),
        const SizedBox(height: 18),
        _buildGaugeStack(speed),
        const SizedBox(height: 24),
        _buildInfoRow(speed),
        const SizedBox(height: 26),
        _buildControlButtons(isDemoRunning, isBooting),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Status Row ───────────────────────────────────────────────────────────

  Widget _buildStatusRow(bool isDemoRunning, bool isBooting) {
    final String label = isBooting
        ? 'SYSTEM INITIALIZING'
        : isDemoRunning
            ? 'SIMULATION RUNNING'
            : 'SYSTEM STANDBY';

    final Color dotColor = isBooting
        ? AppColors.driveModeComfort
        : isDemoRunning
            ? AppColors.statusActive
            : AppColors.statusIdle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape:    BoxShape.circle,
            color:    dotColor,
            boxShadow: (isDemoRunning || isBooting)
                ? [BoxShadow(color: dotColor.withValues(alpha: 0.6),
                    blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
        ),
        const SizedBox(width: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: TextStyle(
            fontSize:      9,
            fontWeight:    FontWeight.w700,
            letterSpacing: 2.8,
            color:         dotColor,
          ),
          child: Text(label),
        ),
      ],
    );
  }

  // ─── Gauge Stack ──────────────────────────────────────────────────────────

  Widget _buildGaugeStack(double speed) {
    return LayoutBuilder(builder: (context, constraints) {
      final double gaugeSize = (constraints.maxWidth * 0.90).clamp(220.0, 390.0);

      return Center(
        child: SizedBox(
          width: gaugeSize, height: gaugeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Layer 1: Gauge face — RepaintBoundary so glow-only repaints
              // don't retrigger the needle layer and vice-versa
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(gaugeSize, gaugeSize),
                  painter: GaugePainter(speed: speed),
                ),
              ),

              // Layer 2: Needle — repaints every animation tick
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(gaugeSize, gaugeSize),
                  painter: NeedlePainter(speed: speed),
                ),
              ),

              // Layer 3: Center digital readout
              _buildCenterDisplay(speed),
            ],
          ),
        ),
      );
    });
  }

  // ─── Center Display ───────────────────────────────────────────────────────

  Widget _buildCenterDisplay(double speed) {
    final String mode = _driveMode(speed);
    final Color  modeColor = _driveModeColor(speed);

    return Transform.translate(
      offset: const Offset(0, 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speed number — zero-padded to 3 digits for stability
          Text(
            speed.round().toString().padLeft(3, '0'),
            style: const TextStyle(
              fontSize:      50,
              fontWeight:    FontWeight.w200, // ultra-thin luxury weight
              color:         AppColors.speedDigit,
              letterSpacing: -2.0,
              height:        1.0,
            ),
          ),

          const SizedBox(height: 1),

          // KM/H label
          const Text(
            'KM/H',
            style: TextStyle(
              fontSize:      9,
              fontWeight:    FontWeight.w600,
              letterSpacing: 4.5,
              color:         AppColors.speedUnit,
            ),
          ),

          const SizedBox(height: 7),

          // Drive mode chip — animates color change between modes
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize:      8,
              fontWeight:    FontWeight.w800,
              letterSpacing: 3.5,
              color:         modeColor,
            ),
            child: Text('— $mode —'),
          ),
        ],
      ),
    );
  }

  String _driveMode(double speed) {
    if (speed < 80)  return 'COMFORT';
    if (speed < 160) return 'SPORT';
    if (speed < 250) return 'SPORT+';
    return 'TRACK';
  }

  Color _driveModeColor(double speed) {
    if (speed < 80)  return AppColors.driveModeComfort;
    if (speed < 160) return AppColors.driveModeSport;
    return AppColors.driveMode;
  }

  // ─── Info Row ─────────────────────────────────────────────────────────────

  Widget _buildInfoRow(double speed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip('PEAK', '${_demoSpeeds.reduce((a, b) => a > b ? a : b).round()} KM/H'),
        _divider(),
        _chip('TARGET', '${_targetSpeed.round()} KM/H'),
        _divider(),
        _chip('MODE', _driveMode(speed)),
      ],
    );
  }

  Widget _chip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize:      7,
            fontWeight:    FontWeight.w700,
            letterSpacing: 2,
            color:         AppColors.speedUnit,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize:      11,
            fontWeight:    FontWeight.w500,
            color:         AppColors.speedDigit,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18),
    width: 1,
    height: 22,
    color: AppColors.btnInactiveBorder,
  );

  // ─── Control Buttons ──────────────────────────────────────────────────────

  Widget _buildControlButtons(bool isDemoRunning, bool isBooting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Row(
        children: [
          Expanded(
            child: DemoControlButton(
              label:       'START',
              icon:        Icons.play_arrow_rounded,
              isActive:    !isDemoRunning && !isBooting,
              activeColor: AppColors.btnActiveBorder,
              onPressed:   (isDemoRunning || isBooting) ? null : _startDemo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DemoControlButton(
              label:       'STOP',
              icon:        Icons.stop_rounded,
              isActive:    isDemoRunning,
              activeColor: const Color(0xFF404050),
              onPressed:   isDemoRunning ? _stopDemo : null,
            ),
          ),
        ],
      ),
    );
  }
}
