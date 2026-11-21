import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A button that fires only after being held for [duration]; the fill shows
/// progress. Prevents ending a run with an accidental tap.
class HoldButton extends StatefulWidget {
  final String label;
  final VoidCallback onComplete;
  final Duration duration;

  const HoldButton({
    super.key,
    required this.label,
    required this.onComplete,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener((s) {
    if (s == AnimationStatus.completed) {
      widget.onComplete();
      _ctrl.reset();
    }
  });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_ctrl.isAnimating) _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      label: widget.label,
      onLongPress: widget.onComplete,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder:
              (context, _) => Container(
                height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.accent, width: 1.5),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _ctrl.value,
                      heightFactor: 1,
                      child: ColoredBox(color: c.accent),
                    ),
                    Center(
                      // The Semantics above already announces the label.
                      child: ExcludeSemantics(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _ctrl.value > 0.5 ? c.onAccent : c.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
