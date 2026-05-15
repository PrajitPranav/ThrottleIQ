// demo_control_button.dart — Premium automotive-style control button.
//
// Uses GestureDetector + AnimatedContainer for:
//   • Smooth active/inactive color transitions
//   • Glowing border when active
//   • No default Material ink splash (keeps the custom look clean)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';

class DemoControlButton extends StatefulWidget {
  final String        label;
  final IconData      icon;
  final bool          isActive;
  final Color         activeColor;
  final VoidCallback? onPressed;

  const DemoControlButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    this.onPressed,
  });

  @override
  State<DemoControlButton> createState() => _DemoControlButtonState();
}

class _DemoControlButtonState extends State<DemoControlButton> {
  bool _pressed = false; // tracks press state for a subtle press-in effect

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = false);
    HapticFeedback.lightImpact(); // subtle tactile on press
    widget.onPressed?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final bool  enabled     = widget.onPressed != null;
    final Color accentColor = widget.activeColor;

    // Colors shift based on active/inactive/pressed state
    final Color bgColor = widget.isActive
        ? accentColor.withValues(alpha: 0.15)
        : enabled 
            ? (_pressed ? accentColor.withValues(alpha: 0.22) : accentColor.withValues(alpha: 0.10))
            : AppColors.btnInactiveFill;

    final Color borderColor = widget.isActive
        ? accentColor.withValues(alpha: 0.6)
        : enabled
            ? accentColor.withValues(alpha: _pressed ? 0.9 : 0.45)
            : AppColors.btnInactiveBorder;

    final Color contentColor = widget.isActive
        ? accentColor
        : enabled
            ? accentColor.withValues(alpha: _pressed ? 1.0 : 0.80)
            : AppColors.statusIdle;

    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve:    Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color:        bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: enabled && widget.isActive
                ? [
                    BoxShadow(
                      color:       accentColor.withValues(alpha: 0.18),
                      blurRadius:  16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: contentColor, size: 17),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize:     11,
                  fontWeight:   FontWeight.w700,
                  letterSpacing: 2.5,
                  color:        contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
