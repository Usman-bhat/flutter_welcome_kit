/// Enum defining the animation type for tooltip appearance
enum StepAnimation {
  /// Fade in while sliding up
  fadeSlideUp,

  /// Fade in while sliding down
  fadeSlideDown,

  /// Fade in while sliding from left
  fadeSlideLeft,

  /// Fade in while sliding from right
  fadeSlideRight,

  /// Scale up from center
  scale,

  /// Bounce with overshoot
  bounce,

  /// Rotate while fading in
  rotate,

  /// Simple fade in
  fade,

  /// No animation
  none,
}

/// Enum defining the shape of the spotlight highlight
enum HighlightShape {
  /// Rounded rectangle (default)
  rounded,

  /// Perfect circle centered on widget
  circle,

  /// Pill shape (fully rounded edges)
  pill,

  /// Sharp rectangle with no rounding
  rectangle,
}

/// Enum defining preferred tooltip position relative to target
enum TooltipPosition {
  /// Automatically determine best position
  auto,

  /// Force tooltip to appear above target
  top,

  /// Force tooltip to appear below target
  bottom,

  /// Force tooltip to appear left of target
  left,

  /// Force tooltip to appear right of target
  right,
}

/// Enum defining the style of progress indicator
enum ProgressIndicatorStyle {
  /// Dot indicators
  dots,

  /// Text format: "2 of 5"
  text,

  /// Text format: "2/5"
  textCompact,

  /// No progress indicator
  none,
}
