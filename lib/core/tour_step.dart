import 'package:flutter/material.dart';
import 'enums.dart';

/// Represents a single step in the onboarding tour.
///
/// Each step defines which widget to highlight, what content to show in the
/// tooltip, and how the step should behave and appear.
class TourStep {
  /// The GlobalKey of the widget to highlight
  final GlobalKey key;

  /// Title text displayed in the tooltip header
  final String title;

  /// Description text displayed in the tooltip body
  final String description;

  /// Background color of the tooltip card
  final Color backgroundColor;

  /// How long to show this step before auto-advancing (if not interactive)
  final Duration duration;

  /// Custom label for the primary button (defaults to "Next" or "Done")
  final String? buttonLabel;

  /// Whether this is the last step in the tour
  final bool isLast;

  // ============ NEW v2.0 Features ============

  /// Animation type for the tooltip appearance
  final StepAnimation animation;

  /// Shape of the spotlight highlight around the target widget
  final HighlightShape highlightShape;

  /// Whether to show a pulsing animation around the highlighted widget
  final bool showPulse;

  /// Custom widget to display in the tooltip (replaces title/description if set)
  final Widget? customContent;

  /// Whether to show step progress indicator
  final bool showProgress;

  /// Style of progress indicator to display
  final ProgressIndicatorStyle progressStyle;

  /// Whether to show a "Previous" button (for going back)
  final bool showPreviousButton;

  /// Whether to show a "Skip" button to skip the entire tour
  final bool showSkipButton;

  /// Custom padding around the spotlight cutout
  final double spotlightPadding;

  /// Border radius for the spotlight (only for rounded/rectangle shapes)
  final double spotlightBorderRadius;

  /// Whether tapping the highlighted widget should advance to next step
  final bool allowTargetTap;

  /// Preferred position for the tooltip relative to the target
  final TooltipPosition preferredPosition;

  /// Text style for the title
  final TextStyle? titleStyle;

  /// Text style for the description
  final TextStyle? descriptionStyle;

  /// Custom icon to show before the title
  final IconData? icon;

  /// Color of the icon
  final Color? iconColor;

  /// Callback fired when this step is displayed.
  /// Useful for feature discovery - mark steps as "seen" by the user.
  final VoidCallback? onDisplay;

  const TourStep({
    required this.key,
    required this.title,
    required this.description,
    this.backgroundColor = Colors.white,
    this.duration = const Duration(seconds: 4),
    this.buttonLabel,
    this.isLast = false,
    // v2.0 defaults
    this.animation = StepAnimation.fadeSlideUp,
    this.highlightShape = HighlightShape.rounded,
    this.showPulse = false,
    this.customContent,
    this.showProgress = true,
    this.progressStyle = ProgressIndicatorStyle.dots,
    this.showPreviousButton = true,
    this.showSkipButton = true,
    this.spotlightPadding = 8.0,
    this.spotlightBorderRadius = 12.0,
    this.allowTargetTap = false,
    this.preferredPosition = TooltipPosition.auto,
    this.titleStyle,
    this.descriptionStyle,
    this.icon,
    this.iconColor,
    this.onDisplay,
  });
}
