import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_welcome_kit/core/tour_step.dart';
import 'package:flutter_welcome_kit/core/enums.dart';
import 'package:flutter_welcome_kit/widgets/progress_indicator.dart';

enum ArrowDirection { up, down, left, right }

/// A tooltip card that displays tour step information.
///
/// Supports smart positioning, multiple animations, progress indicators,
/// navigation buttons, and custom content.
class TooltipCard extends StatefulWidget {
  /// The tour step to display
  final TourStep step;

  /// Rectangle of the target widget
  final Rect targetRect;

  /// Current step index (0-based)
  final int currentStepIndex;

  /// Total number of steps in the tour
  final int totalSteps;

  /// Callback when "Next" is pressed
  final VoidCallback onNext;

  /// Callback when "Previous" is pressed
  final VoidCallback onPrevious;

  /// Callback when "Skip" is pressed
  final VoidCallback onSkip;

  /// Duration of the tooltip animation
  final Duration animationDuration;

  /// Curve for the tooltip animation
  final Curve animationCurve;

  const TooltipCard({
    super.key,
    required this.step,
    required this.targetRect,
    this.hasTarget = true,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    this.dismissOnBarrierTap = true,
    required this.dontShowAgainText,
    this.onDontShowAgain,
    this.dontShowAgainStyle,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// Whether this step has a real target widget.
  ///
  /// When `false` the tooltip is positioned at the screen centre (or as
  /// specified by [TourStep.preferredPosition]) and no arrow is drawn.
  final bool hasTarget;

  /// Whether to dismiss the tour when tapping outside the tooltip
  final bool dismissOnBarrierTap;

  /// Custom text for the "Don't show again" button
  final String dontShowAgainText;

  /// Callback for the "Don't show again" button
  final VoidCallback? onDontShowAgain;

  /// Custom style for the "Don't show again" button
  final ButtonStyle? dontShowAgainStyle;

  @override
  State<TooltipCard> createState() => _TooltipCardState();
}

class _TooltipCardState extends State<TooltipCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  static const double _cardWidth = 280.0;
  static const double _cardPadding = 20.0;
  static const double _arrowSize = 12.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();

    // Auto-advance if not last step and duration is set
    if (!widget.step.isLast && widget.step.duration != null) {
      Future.delayed(widget.step.duration!, () {
        if (mounted) {
          widget.onNext();
        }
      });
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(curve);

    // Slide direction based on animation type
    Offset slideBegin;
    switch (widget.step.animation) {
      case StepAnimation.fadeSlideUp:
        slideBegin = const Offset(0, 0.3);
        break;
      case StepAnimation.fadeSlideDown:
        slideBegin = const Offset(0, -0.3);
        break;
      case StepAnimation.fadeSlideLeft:
        slideBegin = const Offset(0.3, 0);
        break;
      case StepAnimation.fadeSlideRight:
        slideBegin = const Offset(-0.3, 0);
        break;
      default:
        slideBegin = Offset.zero;
    }
    _slideAnimation =
        Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculate the best position for the tooltip and arrow direction.
  ///
  /// When [TooltipCard.hasTarget] is false or the preferred position is
  /// [TooltipPosition.center], the card is centred on screen and no arrow
  /// direction is meaningful (caller should skip drawing the arrow).
  (Offset position, ArrowDirection arrowDir) _calculatePositionAndArrow(
      Size screenSize) {
    if (screenSize.width <= 0 || screenSize.height <= 0) {
      return (Offset.zero, ArrowDirection.up);
    }

    const double estimatedCardHeight = 180.0;

    // ── Centre positioning (no target, or explicitly requested) ─────────────
    final bool wantsCenter = widget.step.preferredPosition == TooltipPosition.center ||
        (!widget.hasTarget && widget.step.preferredPosition == TooltipPosition.auto);

    if (wantsCenter) {
      final dx = (screenSize.width - _cardWidth) / 2;
      final dy = (screenSize.height - estimatedCardHeight) / 2;
      return (Offset(dx, dy), ArrowDirection.up); // arrow direction is unused
    }

    // ── Target-relative positioning ──────────────────────────────────────────
    final targetCenter = widget.targetRect.center;
    const double gap = 16.0;

    final spaceAbove = widget.targetRect.top;
    final spaceBelow = screenSize.height - widget.targetRect.bottom;
    final spaceRight = screenSize.width - widget.targetRect.right;

    ArrowDirection arrowDir;
    double dx, dy;

    switch (widget.step.preferredPosition) {
      case TooltipPosition.top:
        arrowDir = ArrowDirection.down;
        dy = widget.targetRect.top - estimatedCardHeight - gap;
        dx = targetCenter.dx - _cardWidth / 2;
        break;
      case TooltipPosition.bottom:
        arrowDir = ArrowDirection.up;
        dy = widget.targetRect.bottom + gap;
        dx = targetCenter.dx - _cardWidth / 2;
        break;
      case TooltipPosition.left:
        arrowDir = ArrowDirection.right;
        dx = widget.targetRect.left - _cardWidth - gap;
        dy = targetCenter.dy - estimatedCardHeight / 2;
        break;
      case TooltipPosition.right:
        arrowDir = ArrowDirection.left;
        dx = widget.targetRect.right + gap;
        dy = targetCenter.dy - estimatedCardHeight / 2;
        break;
      case TooltipPosition.center: // already handled above
      case TooltipPosition.auto:
        // Auto: prefer bottom, then top, then sides
        if (spaceBelow >= estimatedCardHeight + gap) {
          arrowDir = ArrowDirection.up;
          dy = widget.targetRect.bottom + gap;
          dx = targetCenter.dx - _cardWidth / 2;
        } else if (spaceAbove >= estimatedCardHeight + gap) {
          arrowDir = ArrowDirection.down;
          dy = widget.targetRect.top - estimatedCardHeight - gap;
          dx = targetCenter.dx - _cardWidth / 2;
        } else if (spaceRight >= _cardWidth + gap) {
          arrowDir = ArrowDirection.left;
          dx = widget.targetRect.right + gap;
          dy = targetCenter.dy - estimatedCardHeight / 2;
        } else {
          arrowDir = ArrowDirection.right;
          dx = widget.targetRect.left - _cardWidth - gap;
          dy = targetCenter.dy - estimatedCardHeight / 2;
        }
        break;
    }

    // Clamp position to screen bounds
    dx = dx.clamp(_cardPadding, screenSize.width - _cardWidth - _cardPadding);
    dy = dy.clamp(
        _cardPadding, screenSize.height - estimatedCardHeight - _cardPadding);

    return (Offset(dx, dy), arrowDir);
  }

  /// Calculate arrow position on the card edge pointing toward the target
  Offset _calculateArrowOffset(Offset cardPosition, ArrowDirection arrowDir) {
    final targetCenter = widget.targetRect.center;

    switch (arrowDir) {
      case ArrowDirection.up:
        // Arrow at top of card, pointing up toward target
        final arrowX =
            (targetCenter.dx - cardPosition.dx).clamp(20.0, _cardWidth - 20.0);
        return Offset(arrowX - _arrowSize / 2, -_arrowSize);
      case ArrowDirection.down:
        // Arrow at bottom of card, pointing down toward target
        final arrowX =
            (targetCenter.dx - cardPosition.dx).clamp(20.0, _cardWidth - 20.0);
        return Offset(arrowX - _arrowSize / 2,
            -1); // Will be positioned at bottom in build
      case ArrowDirection.left:
        // Arrow at left of card, pointing left toward target
        final arrowY = (targetCenter.dy - cardPosition.dy).clamp(30.0, 150.0);
        return Offset(-_arrowSize, arrowY - _arrowSize / 2);
      case ArrowDirection.right:
        // Arrow at right of card, pointing right toward target
        final arrowY = (targetCenter.dy - cardPosition.dy).clamp(30.0, 150.0);
        return Offset(-1,
            arrowY - _arrowSize / 2); // Will be positioned at right in build
    }
  }

  Widget _buildAnimatedContent(Widget child) {
    switch (widget.step.animation) {
      case StepAnimation.none:
        return child;
      case StepAnimation.fade:
        return FadeTransition(opacity: _fadeAnimation, child: child);
      case StepAnimation.scale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: child),
        );
      case StepAnimation.bounce:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        );
      case StepAnimation.rotate:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, ch) => Transform.rotate(
              angle: _rotateAnimation.value,
              child: ch,
            ),
            child: child,
          ),
        );
      case StepAnimation.fadeSlideUp:
      case StepAnimation.fadeSlideDown:
      case StepAnimation.fadeSlideLeft:
      case StepAnimation.fadeSlideRight:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final (cardPosition, arrowDir) = _calculatePositionAndArrow(screenSize);
    final arrowOffset = _calculateArrowOffset(cardPosition, arrowDir);

    final cardColor =
        widget.step.backgroundColor ?? Theme.of(context).primaryColor;
    final textColor = _getContrastingTextColor(cardColor);

    final buttonLabel =
        widget.step.buttonLabel ?? (widget.step.isLast ? 'Done' : 'Next');

    final isFirstStep = widget.currentStepIndex == 0;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onSkip();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onNext();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (!isFirstStep) widget.onPrevious();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          // Invisible tap catcher for dismissing
          GestureDetector(
            onTap: widget.dismissOnBarrierTap ? widget.onSkip : () {},
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.transparent,
            ),
          ),

          // Tooltip card
          Positioned(
            top: cardPosition.dy,
            left: cardPosition.dx,
            child: _buildAnimatedContent(
              _buildCard(cardColor, textColor, buttonLabel, isFirstStep,
                  arrowDir, arrowOffset),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Color cardColor, Color textColor, String buttonLabel,
      bool isFirstStep, ArrowDirection arrowDir, Offset arrowOffset) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card
        Container(
          width: _cardWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and close/skip button
              Row(
                children: [
                  if (widget.step.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        widget.step.icon,
                        color: widget.step.iconColor ?? textColor,
                        size: 20,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      widget.step.title,
                      style: widget.step.titleStyle ??
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  if (widget.step.showCloseButton)
                    IconButton(
                      onPressed: widget.onSkip,
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      tooltip: widget.step.skipButtonLabel ?? (widget.step.showCloseButton ? 'Close' : 'Skip'),
                      color: textColor.withValues(alpha: 0.6),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Custom content or description
              if (widget.step.customContent != null)
                widget.step.customContent!
              else
                Text(
                  widget.step.description,
                  style: widget.step.descriptionStyle ??
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withValues(alpha: 0.8),
                          ),
                ),

              const SizedBox(height: 16),

              // New Navigation Layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Don't show again or Skip button
                  if (widget.onDontShowAgain != null)
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onDontShowAgain,
                        style: widget.dontShowAgainStyle ??
                            TextButton.styleFrom(
                              foregroundColor: textColor.withValues(alpha: 0.7),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                            ),
                        child: Text(
                          widget.dontShowAgainText,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                                decoration: TextDecoration.underline,
                              ),
                          maxLines: 1,
                        ),
                      ),
                    )
                  else if (widget.step.showSkipButton)
                    TextButton(
                      onPressed: widget.onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor.withValues(alpha: 0.7),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        widget.step.skipButtonLabel ?? 'Skip',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withValues(alpha: 0.8),
                            ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  const SizedBox(width: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Previous button
                      if (!isFirstStep && widget.step.showPreviousButton)
                        widget.step.previousButtonLabel != null
                            ? TextButton(
                                onPressed: widget.onPrevious,
                                style: TextButton.styleFrom(
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(widget.step.previousButtonLabel!),
                              )
                            : IconButton(
                                onPressed: widget.onPrevious,
                                icon: const Icon(Icons.chevron_left),
                                iconSize: 20,
                                color: textColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),

                      if (widget.step.showProgress)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TourProgressIndicator(
                            currentStep: widget.currentStepIndex,
                            totalSteps: widget.totalSteps,
                            style: ProgressIndicatorStyle.textCompact,
                            textStyle: TextStyle(color: textColor, fontSize: 13),
                            activeColor: textColor,
                            inactiveColor: textColor.withValues(alpha: 0.3),
                          ),
                        ),

                      // Next/Done button
                      if (!widget.step.isLast)
                        widget.step.buttonLabel != null && widget.step.buttonLabel != 'Next'
                            ? TextButton(
                                onPressed: widget.onNext,
                                style: TextButton.styleFrom(
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(widget.step.buttonLabel!),
                              )
                            : IconButton(
                                onPressed: widget.onNext,
                                tooltip: buttonLabel,
                                icon: const Icon(Icons.chevron_right),
                                iconSize: 20,
                                color: textColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),

                      if (widget.step.isLast)
                        widget.step.buttonLabel != null && widget.step.buttonLabel != 'Done'
                            ? TextButton(
                                onPressed: widget.onNext,
                                style: TextButton.styleFrom(
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(widget.step.buttonLabel!),
                              )
                            : IconButton(
                                onPressed: widget.onNext,
                                tooltip: buttonLabel,
                                icon: const Icon(Icons.check_circle_outline),
                                iconSize: 20,
                                color: textColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arrow pointing toward target — only when there is a real target
        if (widget.hasTarget)
          _buildArrow(arrowDir, arrowOffset, cardColor),
      ],
    );
  }

  Widget _buildArrow(ArrowDirection direction, Offset offset, Color color) {
    // Position the arrow at the correct edge of the card
    double? top, left, bottom, right;

    switch (direction) {
      case ArrowDirection.up:
        top = offset.dy;
        left = offset.dx;
        break;
      case ArrowDirection.down:
        bottom = 0;
        left = offset.dx;
        break;
      case ArrowDirection.left:
        top = offset.dy;
        left = offset.dx;
        break;
      case ArrowDirection.right:
        top = offset.dy;
        right = 0;
        break;
    }

    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: CustomPaint(
        size: const Size(_arrowSize, _arrowSize),
        painter: _ArrowPainter(
          color: color,
          direction: direction,
        ),
      ),
    );
  }

  Color _getContrastingTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;

  _ArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (direction) {
      case ArrowDirection.up:
        // Triangle pointing up
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.down:
        // Triangle pointing down
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ArrowDirection.left:
        // Triangle pointing left
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.right:
        // Triangle pointing right
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
