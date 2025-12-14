import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_welcome_kit/flutter_welcome_kit.dart';

void main() {
  group('Flutter Welcome Kit Tests', () {
    testWidgets('TourStep creates with required parameters', (tester) async {
      final key = GlobalKey();
      final step = TourStep(
        key: key,
        title: 'Test Title',
        description: 'Test Description',
      );

      expect(step.title, 'Test Title');
      expect(step.description, 'Test Description');
      expect(step.isLast, false);
      expect(step.animation, StepAnimation.fadeSlideUp);
      expect(step.highlightShape, HighlightShape.rounded);
      expect(step.showProgress, true);
      expect(step.showPreviousButton, true);
      expect(step.showSkipButton, true);
    });

    testWidgets('TourController initializes correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final key = GlobalKey();
              final controller = TourController(
                context: context,
                steps: [
                  TourStep(
                    key: key,
                    title: 'Step 1',
                    description: 'First step',
                  ),
                ],
              );

              expect(controller.totalSteps, 1);
              expect(controller.currentStepIndex, 0);
              expect(controller.isRunning, false);

              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
    });

    test('StepAnimation enum has all values', () {
      expect(StepAnimation.values.length, 9);
      expect(StepAnimation.values.contains(StepAnimation.fadeSlideUp), true);
      expect(StepAnimation.values.contains(StepAnimation.bounce), true);
      expect(StepAnimation.values.contains(StepAnimation.none), true);
    });

    test('HighlightShape enum has all values', () {
      expect(HighlightShape.values.length, 4);
      expect(HighlightShape.values.contains(HighlightShape.circle), true);
      expect(HighlightShape.values.contains(HighlightShape.pill), true);
      expect(HighlightShape.values.contains(HighlightShape.rounded), true);
    });

    test('ProgressIndicatorStyle enum has all values', () {
      expect(ProgressIndicatorStyle.values.length, 4);
      expect(ProgressIndicatorStyle.values.contains(ProgressIndicatorStyle.dots), true);
      expect(ProgressIndicatorStyle.values.contains(ProgressIndicatorStyle.text), true);
    });
  });
}
