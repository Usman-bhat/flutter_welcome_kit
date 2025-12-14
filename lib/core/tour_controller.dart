import 'package:flutter/material.dart';
import 'package:flutter_welcome_kit/core/tour_step.dart';
import 'package:flutter_welcome_kit/widgets/spotlight.dart';
import 'package:flutter_welcome_kit/widgets/tooltip_card.dart';

/// Controller for managing the onboarding tour lifecycle.
///
/// Create an instance with your steps and context, then call [start] to begin
/// the tour. The controller handles step navigation, overlay management,
/// and callbacks.
class TourController {
  /// List of tour steps to display
  final List<TourStep> steps;

  /// BuildContext for overlay insertion
  final BuildContext context;

  // ============ Callbacks ============

  /// Called when the tour is completed (user finishes last step)
  final VoidCallback? onComplete;

  /// Called when the tour is skipped
  final VoidCallback? onSkip;

  /// Called when the step changes
  final Function(int stepIndex, TourStep step)? onStepChange;

  // ============ Configuration ============

  /// Delay before starting the tour (useful for letting UI settle)
  final Duration? startDelay;

  /// Key for persisting tour completion state
  /// If set, user's completion status is saved and can be checked
  final String? persistenceKey;

  /// Overlay color for the spotlight background
  final Color overlayColor;

  /// Whether to dismiss the tour when tapping outside
  final bool dismissOnBarrierTap;

  OverlayEntry? _overlayEntry;
  int _currentStepIndex = 0;
  bool _isRunning = false;

  TourController({
    required this.context,
    required this.steps,
    this.onComplete,
    this.onSkip,
    this.onStepChange,
    this.startDelay,
    this.persistenceKey,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.7),
    this.dismissOnBarrierTap = false,
  });

  /// Current step index (0-based)
  int get currentStepIndex => _currentStepIndex;

  /// Total number of steps
  int get totalSteps => steps.length;

  /// Whether the tour is currently running
  bool get isRunning => _isRunning;

  /// Current step being displayed
  TourStep? get currentStep =>
      _isRunning && _currentStepIndex < steps.length
          ? steps[_currentStepIndex]
          : null;

  /// Start the tour from the beginning
  Future<void> start() async {
    if (startDelay != null) {
      await Future.delayed(startDelay!);
    }
    _currentStepIndex = 0;
    _isRunning = true;
    _showStep();
  }

  /// Start the tour from a specific step
  Future<void> startFrom(int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= steps.length) return;
    if (startDelay != null) {
      await Future.delayed(startDelay!);
    }
    _currentStepIndex = stepIndex;
    _isRunning = true;
    _showStep();
  }

  /// Move to the next step
  void next() {
    if (_currentStepIndex < steps.length - 1) {
      _currentStepIndex++;
      _showStep();
      onStepChange?.call(_currentStepIndex, steps[_currentStepIndex]);
    } else {
      _complete();
    }
  }

  /// Move to the previous step
  void previous() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _showStep();
      onStepChange?.call(_currentStepIndex, steps[_currentStepIndex]);
    }
  }

  /// Go to a specific step by index
  void goToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < steps.length) {
      _currentStepIndex = stepIndex;
      _showStep();
      onStepChange?.call(_currentStepIndex, steps[_currentStepIndex]);
    }
  }

  /// Skip the tour entirely
  void skip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isRunning = false;
    onSkip?.call();
  }

  /// End the tour (alias for skip, but indicates completion)
  void end() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isRunning = false;
  }

  void _complete() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isRunning = false;
    _saveTourCompleted();
    onComplete?.call();
  }

  void _showStep() {
    _overlayEntry?.remove();

    final step = steps[_currentStepIndex];
    final renderBox =
        step.key.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);

    if (renderBox == null) return;

    final target = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    // Call onDisplay callback for feature discovery tracking
    step.onDisplay?.call();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Spotlight(
            targetRect: target,
            padding: step.spotlightPadding,
            overlayColor: overlayColor,
            shape: step.highlightShape,
            borderRadius: step.spotlightBorderRadius,
            showPulse: step.showPulse,
            onTargetTap: step.allowTargetTap ? next : null,
          ),
          TooltipCard(
            step: step,
            targetRect: target,
            currentStepIndex: _currentStepIndex,
            totalSteps: steps.length,
            onNext: next,
            onPrevious: previous,
            onSkip: skip,
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);

    // Notify step change for first step
    if (_currentStepIndex == 0) {
      onStepChange?.call(_currentStepIndex, step);
    }
  }

  /// Check if the tour has been completed before (requires persistenceKey)
  Future<bool> hasCompletedTour() async {
    if (persistenceKey == null) return false;
    // Note: For actual persistence, integrate with SharedPreferences
    // This is a placeholder - actual implementation needs shared_preferences
    return false;
  }

  /// Reset the tour completion state
  Future<void> resetTourState() async {
    if (persistenceKey == null) return;
    // Note: For actual persistence, integrate with SharedPreferences
  }

  void _saveTourCompleted() {
    if (persistenceKey == null) return;
    // Note: For actual persistence, integrate with SharedPreferences
  }
}