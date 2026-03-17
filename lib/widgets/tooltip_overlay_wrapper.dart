import 'dart:async';
import 'package:flutter/material.dart';
import 'tooltip_card.dart';
import 'package:flutter_welcome_kit/core/tour_step.dart';

/// A wrapper widget for the tooltip overlay.
///
/// This widget manages the timer-based auto-advance and provides
/// a dimmed background with the tooltip card.
class TooltipOverlayWrapper extends StatefulWidget {
  final TourStep step;
  final Rect targetRect;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final String dontShowAgainText;
  final VoidCallback? onDontShowAgain;
  final ButtonStyle? dontShowAgainStyle;

  const TooltipOverlayWrapper({
    super.key,
    required this.step,
    required this.targetRect,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.dontShowAgainText,
    this.onDontShowAgain,
    this.dontShowAgainStyle,
  });

  @override
  State<TooltipOverlayWrapper> createState() => _TooltipOverlayWrapperState();
}

class _TooltipOverlayWrapperState extends State<TooltipOverlayWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-advance if not last step and duration is set
    if (!widget.step.isLast && widget.step.duration != null) {
      Future.delayed(widget.step.duration!, () {
        if (mounted) {
          widget.onNext();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleOutsideTap() {
    if (!widget.step.isLast) {
      widget.onNext();
    } else {
      widget.onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleOutsideTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5), // dimmed background
            ),
          ),
          TooltipCard(
            step: widget.step,
            targetRect: widget.targetRect,
            currentStepIndex: widget.currentStepIndex,
            totalSteps: widget.totalSteps,
            onNext: widget.onNext,
            onPrevious: widget.onPrevious,
            onSkip: widget.onSkip,
            dontShowAgainText: widget.dontShowAgainText,
            onDontShowAgain: widget.onDontShowAgain,
            dontShowAgainStyle: widget.dontShowAgainStyle,
          ),
        ],
      ),
    );
  }
}
