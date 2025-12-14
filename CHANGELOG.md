## 2.0.0

### ✨ New Features

- **Progress Indicators** - Shows step progress as dots or text (e.g., "2 of 5")
- **Custom Widget Support** - Add custom widgets to tooltips via `customContent`
- **Highlight Shapes** - Choose from circle, rectangle, pill, or rounded spotlight shapes
- **Pulse Animation** - Animated pulse effect around highlighted widgets
- **8 Animation Types** - fadeSlideUp, fadeSlideDown, fadeSlideLeft, fadeSlideRight, scale, bounce, rotate, fade
- **Previous Button** - Navigate back to previous steps
- **Skip Button** - Option to skip the entire tour
- **Callbacks** - `onStepChange`, `onComplete`, `onSkip` for tour events
- **Start Delay** - Wait for UI to settle before starting tour
- **Barrier Interaction** - Tap highlighted widget to advance (`allowTargetTap`)
- **Custom Styling** - Custom text styles, icons, and colors per step
- **Preferred Position** - Force tooltip to appear top/bottom/left/right
- **Feature Discovery** - `onDisplay` callback fires when each step is shown

### 🔧 Improvements

- Better contrast detection for text colors
- Keyboard navigation with arrow keys (left/up for previous)
- Smoother animations with configurable curves
- Improved tooltip positioning algorithm
- Added comprehensive documentation

### 📦 New Exports

- `StepAnimation` enum
- `HighlightShape` enum  
- `TooltipPosition` enum
- `ProgressIndicatorStyle` enum
- `TourProgressIndicator` widget

---

## 1.0.0

* Initial stable release
* Features:
  - Smart tooltip positioning system
  - Widget highlighting using GlobalKey
  - Animated tooltips with multiple animation types
  - Customizable colors and styles
  - Auto-advance functionality
  - Keyboard navigation support
  - Responsive design
  - RTL support
  - Accessibility improvements

## 0.0.1

* Initial development release
