# Flutter Welcome Kit 🎉

A beautiful, customizable onboarding/tour guide kit for Flutter apps. Highlight widgets, display tooltips, and guide your users step by step — perfect for tutorials and product tours.

[![pub package](https://img.shields.io/pub/v/flutter_welcome_kit.svg)](https://pub.dev/packages/flutter_welcome_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📸 Demo

![Demo](doc/screenshots/demo.webp)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎯 **Spotlight Overlay** | Highlight any widget with a dark overlay cutout |
| ✨ **8 Animation Types** | fade, slideUp/Down/Left/Right, scale, bounce, rotate |
| 🔵 **4 Highlight Shapes** | Circle, rectangle, pill, rounded rectangle |
| 💫 **Pulse Effect** | Animated pulse ring around highlighted widget |
| 📊 **Progress Indicators** | Dots, text ("Step 2 of 5"), or compact ("2/5") |
| ⏮️ **Full Navigation** | Previous, Next, and Skip buttons |
| 🎨 **Customizable** | Colors, icons, styles, custom content per step |
| 📍 **Smart Positioning** | Tooltip auto-positions to avoid edges |
| ⌨️ **Keyboard Support** | Arrow keys, ESC, Enter/Space navigation |
| 🔔 **Callbacks** | onComplete, onSkip, onStepChange events |
| ⏱️ **Auto-advance** | Configurable timing per step |
| 🌐 **RTL Support** | Works with right-to-left languages |

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_welcome_kit: ^2.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
import 'package:flutter_welcome_kit/flutter_welcome_kit.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. Create GlobalKeys for widgets to highlight
  final addButtonKey = GlobalKey();
  final searchKey = GlobalKey();
  final profileKey = GlobalKey();
  
  late TourController _tourController;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Create the tour controller
      _tourController = TourController(
        context: context,
        steps: [
          TourStep(
            key: addButtonKey,
            title: '➕ Create New',
            description: 'Tap here to add a new item.',
            backgroundColor: Colors.blue,
            animation: StepAnimation.fadeSlideUp,
            showPulse: true,
          ),
          TourStep(
            key: searchKey,
            title: '🔍 Search',
            description: 'Find anything instantly.',
            backgroundColor: Colors.orange,
            highlightShape: HighlightShape.circle,
          ),
          TourStep(
            key: profileKey,
            title: '👤 Your Profile',
            description: 'Manage your account settings.',
            backgroundColor: Colors.purple,
            isLast: true,
            buttonLabel: 'Get Started!',
          ),
        ],
        onComplete: () => print('Tour finished!'),
        onSkip: () => print('Tour skipped'),
      );
      
      // 3. Start the tour
      _tourController.start();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: searchKey,  // Attach the key
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            key: profileKey,  // Attach the key
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: addButtonKey,  // Attach the key
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 📚 API Reference

### TourStep

Configuration for a single tour step.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `GlobalKey` | **required** | Widget to highlight |
| `title` | `String` | **required** | Tooltip title |
| `description` | `String` | **required** | Tooltip description |
| `backgroundColor` | `Color` | `Colors.white` | Tooltip background |
| `duration` | `Duration` | `4 seconds` | Auto-advance delay |
| `buttonLabel` | `String?` | `"Next"/"Done"` | Button text |
| `isLast` | `bool` | `false` | Is this the final step? |
| `animation` | `StepAnimation` | `fadeSlideUp` | Entry animation |
| `highlightShape` | `HighlightShape` | `rounded` | Spotlight shape |
| `showPulse` | `bool` | `false` | Show pulse animation |
| `customContent` | `Widget?` | `null` | Replace description with widget |
| `showProgress` | `bool` | `true` | Show progress indicator |
| `progressStyle` | `ProgressIndicatorStyle` | `dots` | Progress style |
| `showPreviousButton` | `bool` | `true` | Show back button |
| `showSkipButton` | `bool` | `true` | Show close/skip button |
| `spotlightPadding` | `double` | `8.0` | Padding around highlight |
| `spotlightBorderRadius` | `double` | `12.0` | Border radius (rounded shape) |
| `allowTargetTap` | `bool` | `false` | Tap widget to advance |
| `preferredPosition` | `TooltipPosition` | `auto` | Force tooltip position |
| `titleStyle` | `TextStyle?` | `null` | Custom title style |
| `descriptionStyle` | `TextStyle?` | `null` | Custom description style |
| `icon` | `IconData?` | `null` | Icon before title |
| `iconColor` | `Color?` | `null` | Icon color |
| `onDisplay` | `VoidCallback?` | `null` | Callback fired when step is shown |

---

### TourController

Manages the tour lifecycle.

```dart
TourController(
  context: context,
  steps: steps,
  
  // Callbacks
  onComplete: () {},     // Tour finished
  onSkip: () {},         // Tour skipped
  onStepChange: (index, step) {},  // Step changed
  
  // Configuration
  startDelay: Duration(milliseconds: 500),
  overlayColor: Colors.black.withValues(alpha: 0.7),
  dismissOnBarrierTap: false,
);
```

#### Methods

| Method | Description |
|--------|-------------|
| `start()` | Start tour from step 0 |
| `startFrom(int index)` | Start from specific step |
| `next()` | Go to next step |
| `previous()` | Go to previous step |
| `goToStep(int index)` | Jump to specific step |
| `skip()` | Skip/end the tour |
| `end()` | Alias for skip |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentStepIndex` | `int` | Current step (0-based) |
| `totalSteps` | `int` | Total number of steps |
| `isRunning` | `bool` | Is tour currently active |
| `currentStep` | `TourStep?` | Current step object |

---

### Enums

#### StepAnimation

```dart
StepAnimation.fadeSlideUp     // Fade + slide from bottom
StepAnimation.fadeSlideDown   // Fade + slide from top
StepAnimation.fadeSlideLeft   // Fade + slide from right
StepAnimation.fadeSlideRight  // Fade + slide from left
StepAnimation.scale           // Scale up from center
StepAnimation.bounce          // Elastic bounce
StepAnimation.rotate          // Rotate while fading
StepAnimation.fade            // Simple fade in
StepAnimation.none            // No animation
```

#### HighlightShape

```dart
HighlightShape.rounded    // Rounded rectangle (default)
HighlightShape.circle     // Perfect circle
HighlightShape.pill       // Capsule/pill shape
HighlightShape.rectangle  // Sharp corners
```

#### TooltipPosition

```dart
TooltipPosition.auto    // Automatic (default)
TooltipPosition.top     // Force above target
TooltipPosition.bottom  // Force below target
TooltipPosition.left    // Force left of target
TooltipPosition.right   // Force right of target
```

#### ProgressIndicatorStyle

```dart
ProgressIndicatorStyle.dots        // ●● ○ ○ (animated dots)
ProgressIndicatorStyle.text        // "Step 2 of 5"
ProgressIndicatorStyle.textCompact // "2/5"
ProgressIndicatorStyle.none        // No indicator
```

---

## 🎨 Advanced Usage

### Custom Content in Tooltip

```dart
TourStep(
  key: profileKey,
  title: 'Complete Your Profile',
  description: '',
  customContent: Column(
    children: [
      CircleAvatar(radius: 30, child: Icon(Icons.person)),
      SizedBox(height: 12),
      Text('Add a photo to personalize your account'),
      SizedBox(height: 8),
      OutlinedButton(
        onPressed: () {},
        child: Text('Upload Photo'),
      ),
    ],
  ),
)
```

### Different Shapes Demo

```dart
// Circle - great for FABs and icons
TourStep(
  key: fabKey,
  highlightShape: HighlightShape.circle,
  spotlightPadding: 4,
  ...
)

// Pill - great for buttons and chips
TourStep(
  key: buttonKey,
  highlightShape: HighlightShape.pill,
  ...
)

// Rounded - great for cards
TourStep(
  key: cardKey,
  highlightShape: HighlightShape.rounded,
  spotlightBorderRadius: 16,
  ...
)
```

### Callbacks for Analytics

```dart
TourController(
  context: context,
  steps: steps,
  onStepChange: (index, step) {
    analytics.logEvent('tour_step', {
      'step_index': index,
      'step_title': step.title,
    });
  },
  onComplete: () {
    analytics.logEvent('tour_completed');
    prefs.setBool('has_seen_tour', true);
  },
  onSkip: () {
    analytics.logEvent('tour_skipped');
  },
);
```

### Feature Discovery with onDisplay

Use the `onDisplay` callback to track when users see specific features — perfect for progressive disclosure and feature discovery UX patterns:

```dart
// Track which features users have discovered
final Set<String> discoveredFeatures = {};

void markFeatureSeen(String featureId) {
  discoveredFeatures.add(featureId);
  prefs.setStringList('discovered_features', discoveredFeatures.toList());
}

// In your tour steps:
TourStep(
  key: inboxKey,
  title: 'Inbox',
  description: 'You can access incoming messages here.',
  onDisplay: () => markFeatureSeen('inbox'),
),
TourStep(
  key: settingsKey,
  title: 'Settings',
  description: 'Customize your app preferences.',
  onDisplay: () => markFeatureSeen('settings'),
),
```

---

## ⌨️ Keyboard Navigation

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Next step |
| `←` / `↑` | Previous step |
| `ESC` | Skip tour |

---

## 🔧 Troubleshooting

### Widget not highlighting?

Make sure the `GlobalKey` is attached to a widget that's currently visible:

```dart
// ✅ Correct - key is on a visible widget
IconButton(
  key: myKey,
  icon: Icon(Icons.star),
  ...
)

// ❌ Wrong - key is on a widget inside a closed menu
PopupMenuItem(
  key: myKey,  // Won't work if menu is closed!
  ...
)
```

### Tour starts before UI is ready?

Use `startDelay` to wait for widgets to render:

```dart
TourController(
  ...
  startDelay: Duration(milliseconds: 500),
);
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Mohammad Usman**

- GitHub: [@Usman-bhat](https://github.com/Usman-bhat)
- Package: [pub.dev/packages/flutter_welcome_kit](https://pub.dev/packages/flutter_welcome_kit)
