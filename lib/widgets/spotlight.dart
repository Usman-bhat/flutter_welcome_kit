import 'package:flutter/material.dart';
import 'package:flutter_welcome_kit/core/enums.dart';

/// A widget that creates a spotlight overlay effect.
///
/// Displays a dark overlay over the entire screen with a transparent cutout
/// around the target widget. Supports multiple shapes, pulse animations,
/// and tap detection.
class Spotlight extends StatefulWidget {
  /// The rectangle defining the target widget's position and size
  final Rect targetRect;

  /// Extra padding around the target for the cutout
  final double padding;

  /// Color of the overlay (typically semi-transparent black)
  final Color overlayColor;

  /// Shape of the spotlight cutout
  final HighlightShape shape;

  /// Border radius for rounded/rectangle shapes
  final double borderRadius;

  /// Whether to show a pulsing animation around the target
  final bool showPulse;

  /// Callback when the target area is tapped
  final VoidCallback? onTargetTap;

  /// Color of the pulse animation
  final Color pulseColor;

  const Spotlight({
    super.key,
    required this.targetRect,
    this.padding = 8.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.7),
    this.shape = HighlightShape.rounded,
    this.borderRadius = 12.0,
    this.showPulse = false,
    this.onTargetTap,
    this.pulseColor = Colors.white,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    if (widget.showPulse) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(Spotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !oldWidget.showPulse) {
      _pulseController.repeat();
    } else if (!widget.showPulse && oldWidget.showPulse) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetWithPadding = widget.targetRect.inflate(widget.padding);

    return Stack(
      children: [
        // Main spotlight overlay
        GestureDetector(
          onTap: () {}, // Absorb taps on the dark area
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _SpotlightPainter(
              target: targetWithPadding,
              color: widget.overlayColor,
              shape: widget.shape,
              borderRadius: widget.borderRadius,
            ),
          ),
        ),

        // Pulse animation overlay
        if (widget.showPulse)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _PulsePainter(
                  target: targetWithPadding,
                  progress: _pulseAnimation.value,
                  color: widget.pulseColor,
                  shape: widget.shape,
                  borderRadius: widget.borderRadius,
                ),
              );
            },
          ),

        // Target tap area
        if (widget.onTargetTap != null)
          Positioned(
            left: targetWithPadding.left,
            top: targetWithPadding.top,
            width: targetWithPadding.width,
            height: targetWithPadding.height,
            child: GestureDetector(
              onTap: widget.onTargetTap,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect target;
  final Color color;
  final HighlightShape shape;
  final double borderRadius;

  _SpotlightPainter({
    required this.target,
    required this.color,
    required this.shape,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..blendMode = BlendMode.dstOut;

    final overlayPaint = Paint()..color = color;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);

    switch (shape) {
      case HighlightShape.circle:
        final center = target.center;
        final radius = (target.width > target.height
                ? target.width
                : target.height) /
            2;
        canvas.drawCircle(center, radius, paint);
        break;

      case HighlightShape.pill:
        final pillRadius = target.height / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(target, Radius.circular(pillRadius)),
          paint,
        );
        break;

      case HighlightShape.rectangle:
        canvas.drawRect(target, paint);
        break;

      case HighlightShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(target, Radius.circular(borderRadius)),
          paint,
        );
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      target != oldDelegate.target ||
      color != oldDelegate.color ||
      shape != oldDelegate.shape ||
      borderRadius != oldDelegate.borderRadius;
}

class _PulsePainter extends CustomPainter {
  final Rect target;
  final double progress;
  final Color color;
  final HighlightShape shape;
  final double borderRadius;

  _PulsePainter({
    required this.target,
    required this.progress,
    required this.color,
    required this.shape,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pulse expands outward and fades
    final expansion = 20.0 * progress;
    final opacity = (1.0 - progress) * 0.6;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final expandedTarget = target.inflate(expansion);

    switch (shape) {
      case HighlightShape.circle:
        final center = expandedTarget.center;
        final radius = (expandedTarget.width > expandedTarget.height
                ? expandedTarget.width
                : expandedTarget.height) /
            2;
        canvas.drawCircle(center, radius, paint);
        break;

      case HighlightShape.pill:
        final pillRadius = expandedTarget.height / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              expandedTarget, Radius.circular(pillRadius)),
          paint,
        );
        break;

      case HighlightShape.rectangle:
        canvas.drawRect(expandedTarget, paint);
        break;

      case HighlightShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              expandedTarget, Radius.circular(borderRadius + expansion / 2)),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      target != oldDelegate.target ||
      color != oldDelegate.color;
}