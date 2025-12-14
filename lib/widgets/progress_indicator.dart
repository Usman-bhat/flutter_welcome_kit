import 'package:flutter/material.dart';
import 'package:flutter_welcome_kit/core/enums.dart';

/// A widget that displays the current step progress in a tour.
///
/// Supports multiple display styles: dots, text ("Step 2 of 5"),
/// or compact text ("2/5").
class TourProgressIndicator extends StatelessWidget {
  /// The current step index (0-based)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Style of the progress indicator
  final ProgressIndicatorStyle style;

  /// Color for the active/current dot or text
  final Color activeColor;

  /// Color for inactive dots
  final Color inactiveColor;

  /// Size of each dot (for dots style)
  final double dotSize;

  /// Spacing between dots (for dots style)
  final double dotSpacing;

  /// Text style for text-based progress
  final TextStyle? textStyle;

  const TourProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.style = ProgressIndicatorStyle.dots,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white38,
    this.dotSize = 8.0,
    this.dotSpacing = 4.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (style == ProgressIndicatorStyle.none) {
      return const SizedBox.shrink();
    }

    switch (style) {
      case ProgressIndicatorStyle.dots:
        return _buildDots();
      case ProgressIndicatorStyle.text:
        return _buildText('Step ${currentStep + 1} of $totalSteps');
      case ProgressIndicatorStyle.textCompact:
        return _buildText('${currentStep + 1}/$totalSteps');
      case ProgressIndicatorStyle.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isPast = index < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: dotSpacing / 2),
          width: isActive ? dotSize * 2 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive || isPast ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: textStyle ??
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: activeColor.withValues(alpha: 0.8),
          ),
    );
  }
}
