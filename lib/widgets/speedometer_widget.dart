// speedometer_widget.dart — Precision analog cluster controller.


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drive_mode.dart';
import '../services/gps_service.dart';
import 'demo_control_button.dart';
import 'gauge_painter.dart';
import 'needle_painter.dart';

enum _Phase { boot, idle, telemetry }

class SpeedometerWidget extends StatefulWidget {
  final DriveMode driveMode;
  
  const SpeedometerWidget({super.key, required this.driveMode});
  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animatable<double> _anim;

  _Phase _phase       = _Phase.idle;
  double _targetSpeed = 0;
  bool   _pendingStart = false;

  double get _speed => _anim.transform(_ctrl.value).clamp(0.0, 300.0);

  @override
  void initState() {
    super.initState();
    _anim = Tween<double>(begin: 0, end: 0);
    _ctrl = AnimationController(vsync: this)
      ..addListener(() { if (mounted) setState(() {}); })
      ..addStatusListener(_onStatus);
    GpsService().addListener(_onGpsUpdate);
  }

  void _onGpsUpdate() {
    if (_phase != _Phase.telemetry) return;
    final double target = GpsService().currentSpeedKmh;
    if ((target - _targetSpeed).abs() > 0.5) {
      _animateTo(target);
    }
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && _phase == _Phase.boot) {
      if (_pendingStart) {
        _startTelemetry();
      } else {
        setState(() {
          _phase = _Phase.idle;
          _anim  = Tween<double>(begin: 0, end: 0);
          _ctrl.value = 1.0;
        });
      }
    }
  }

  // ── Physically weighted ignition sweep ─────────────────────────────────────
  void _boot() {
    if (!mounted) return;
    _ctrl.stop();
    // 3.8s total duration for a heavy, mechanical sweep feel.
    _ctrl.duration = const Duration(milliseconds: 3800);
    _anim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 300.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 300.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 55,
      ),
    ]);
    _ctrl.forward(from: 0);
  }

  void _animateTo(double target) {
    final double from  = _speed;
    final double delta = (target - from).abs();
    // Faster, snappier duration
    final int    ms    = (delta / 300 * 600 + 200).round().clamp(200, 800);

    _ctrl.stop();
    _ctrl.duration = Duration(milliseconds: ms);
    _anim = Tween<double>(begin: from, end: target)
        .chain(CurveTween(curve: Curves.easeOutCubic)); // Mechanical cubic ease out
    _ctrl.forward(from: 0);
    _targetSpeed = target;
  }

  void _triggerStartSequence() {
    if (_phase != _Phase.idle) return;
    setState(() {
      _phase = _Phase.boot;
      _pendingStart = true;
    });
    _boot();
  }

  void _startTelemetry() {
    if (_phase == _Phase.telemetry) return;
    _ctrl.stop();
    setState(() { _phase = _Phase.telemetry; });
    GpsService().startTelemetry();
    _animateTo(GpsService().currentSpeedKmh);
  }

  void _stopTelemetry() {
    GpsService().stopTelemetry();
    setState(() { _phase = _Phase.idle; _pendingStart = false; });
    _animateTo(0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    GpsService().removeListener(_onGpsUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double spd        = _speed;
    final bool   isTelemetry = _phase == _Phase.telemetry;
    final bool   isBooting  = _phase == _Phase.boot;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statusRow(isTelemetry, isBooting),
        const SizedBox(height: 18),
        _gaugeStack(spd),
        const SizedBox(height: 24),
        _infoRow(spd),
        const SizedBox(height: 26),
        _buttons(isTelemetry, isBooting),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statusRow(bool isTelemetry, bool isBooting) {
    final String txt = isBooting ? 'System Boot'
        : isTelemetry ? 'Telemetry Active' : 'System Standby';
    final Color  c   = isBooting ? const Color(0xFF4F6B8F)
        : isTelemetry ? const Color(0xFF5A7D65) : const Color(0xFF4A4A52);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c),
        ),
        const SizedBox(width: 8),
        Text(txt.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: c)),
      ],
    );
  }

  Widget _gaugeStack(double spd) {
    return LayoutBuilder(builder: (ctx, con) {
      final double sz = (con.maxWidth * 0.90).clamp(220.0, 390.0);
      return Center(
        child: SizedBox(
          width: sz, height: sz,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Stack(
              key: ValueKey(widget.driveMode),
              alignment: Alignment.center, 
              children: [
                RepaintBoundary(child: CustomPaint(
                  size: Size(sz, sz), painter: GaugePainter(speed: spd, driveMode: widget.driveMode))),
                RepaintBoundary(child: CustomPaint(
                  size: Size(sz, sz), painter: NeedlePainter(speed: spd, driveMode: widget.driveMode))),
                _centerDisplay(spd, widget.driveMode),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _centerDisplay(double spd, DriveMode driveMode) {
    final String mode = driveMode.label;
    final Color  mc   = driveMode.accent;
    return Transform.translate(
      offset: const Offset(0, 50),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(spd.round().toString().padLeft(3, '0'),
          style: GoogleFonts.inter(fontSize: 52, fontWeight: FontWeight.w300,
              color: Colors.white, letterSpacing: -2.0, height: 1.0)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('KM/H', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                letterSpacing: 2.5, color: const Color(0xFF8A8A94))),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: mc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: mc.withValues(alpha: 0.5), width: 0.5),
              ),
              child: Text(mode, style: GoogleFonts.inter(fontSize: 6, fontWeight: FontWeight.w700,
                  letterSpacing: 1.0, color: mc)),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _infoRow(double spd) {
    return ListenableBuilder(
      listenable: GpsService(),
      builder: (context, _) {
        final topSpeed = GpsService().topSpeed;
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _chip('PEAK', '${topSpeed.round()} KM/H'),
          _divider(),
          _chip('TARGET', '${_targetSpeed.round()} KM/H'),
        ]);
      }
    );
  }

  Widget _chip(String label, String value) => Column(children: [
    Text(label, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600,
        letterSpacing: 1.5, color: const Color(0xFF5E5E68))),
    const SizedBox(height: 3),
    Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
        color: Colors.white, letterSpacing: 0.2)),
  ]);

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    width: 1, height: 20, color: const Color(0xFF1E1E22));

  Widget _buttons(bool isTelemetry, bool isBooting) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 44),
    child: Row(children: [
      Expanded(child: DemoControlButton(
        label: 'START', icon: Icons.play_arrow_rounded,
        isActive: isTelemetry, // glows green when active
        activeColor: const Color(0xFF4ADE80), // Premium green
        onPressed: (isTelemetry || isBooting) ? null : _triggerStartSequence,
      )),
      const SizedBox(width: 14),
      Expanded(child: DemoControlButton(
        label: 'STOP', icon: Icons.stop_rounded,
        isActive: false, // no permanent glow, only visual press state
        activeColor: const Color(0xFFEF4444), // Premium red
        onPressed: isTelemetry ? _stopTelemetry : null,
      )),
    ]),
  );

}
