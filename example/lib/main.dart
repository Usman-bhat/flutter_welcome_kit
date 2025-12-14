import 'package:flutter/material.dart';
import 'package:flutter_welcome_kit/flutter_welcome_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Color(0xFF21262D),
          surface: Color(0xFF161B22),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF21262D),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const TaskManagerDemo(),
    );
  }
}

/// A practical demo showcasing the Flutter Welcome Kit in a real app context
class TaskManagerDemo extends StatefulWidget {
  const TaskManagerDemo({super.key});

  @override
  State<TaskManagerDemo> createState() => _TaskManagerDemoState();
}

class _TaskManagerDemoState extends State<TaskManagerDemo> {
  // Global keys for tour targets
  final GlobalKey _addTaskKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _taskCardKey = GlobalKey();
  final GlobalKey _priorityBadgeKey = GlobalKey();
  final GlobalKey _checkboxKey = GlobalKey();
  final GlobalKey _statsCardKey = GlobalKey();

  late TourController _tourController;
  bool _showTour = true;

  // Sample task data
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Review pull requests', 'priority': 'high', 'done': false},
    {'title': 'Update documentation', 'priority': 'medium', 'done': true},
    {'title': 'Fix login bug', 'priority': 'high', 'done': false},
    {'title': 'Team standup meeting', 'priority': 'low', 'done': true},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTour();
      // Auto-start tour for demo purposes
      if (_showTour) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _tourController.start();
        });
      }
    });
  }

  void _initTour() {
    _tourController = TourController(
      context: context,
      steps: [
        TourStep(
          key: _addTaskKey,
          title: '➕ Create Tasks',
          description: 'Tap here to add a new task to your list. You can set priority levels and due dates.',
          backgroundColor: Colors.indigo,
          animation: StepAnimation.fadeSlideUp,
          highlightShape: HighlightShape.circle,
          showPulse: true,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _filterKey,
          title: '🔍 Filter Tasks',
          description: 'Filter your tasks by status, priority, or date to focus on what matters.',
          backgroundColor: Colors.teal,
          animation: StepAnimation.fadeSlideDown,
          highlightShape: HighlightShape.circle,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _searchKey,
          title: '🔎 Quick Search',
          description: 'Instantly find any task by typing keywords. Works across all your projects.',
          backgroundColor: Colors.orange,
          animation: StepAnimation.scale,
          highlightShape: HighlightShape.circle,
          showPulse: true,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _taskCardKey,
          title: '📋 Task Cards',
          description: 'Each task shows its title, priority, and completion status at a glance.',
          backgroundColor: Colors.purple,
          animation: StepAnimation.fadeSlideLeft,
          highlightShape: HighlightShape.rounded,
          spotlightPadding: 4,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _priorityBadgeKey,
          title: '🏷️ Priority Badges',
          description: 'Color-coded badges help you identify urgent tasks quickly.',
          backgroundColor: Colors.red.shade700,
          animation: StepAnimation.bounce,
          highlightShape: HighlightShape.pill,
          showPulse: true,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _checkboxKey,
          title: '✓ Complete Tasks',
          description: 'Tap the checkbox to mark a task as complete. Your progress is saved automatically.',
          backgroundColor: Colors.green,
          animation: StepAnimation.scale,
          highlightShape: HighlightShape.circle,
          duration: const Duration(seconds: 6),
        ),
        TourStep(
          key: _statsCardKey,
          title: '📊 Your Progress',
          description: 'Track your productivity with real-time statistics and insights.',
          backgroundColor: Colors.blue,
          animation: StepAnimation.fadeSlideUp,
          highlightShape: HighlightShape.rounded,
          isLast: true,
          buttonLabel: 'Get Started! 🚀',
          duration: const Duration(seconds: 8),
        ),
      ],
      startDelay: const Duration(milliseconds: 300),
      onComplete: () {
        setState(() => _showTour = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 You\'re all set! Start managing your tasks.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onSkip: () {
        setState(() => _showTour = false);
      },
      onStepChange: (index, step) {
        debugPrint('Tour step ${index + 1}: ${step.title}');
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((t) => t['done'] == true).length;
    final totalCount = _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            key: _filterKey,
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            key: _searchKey,
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats card
            Card(
              key: _statsCardKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedCount of $totalCount tasks',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: completedCount / totalCount,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation(Colors.green),
                          ),
                          Center(
                            child: Text(
                              '${((completedCount / totalCount) * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Task list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Restart tour
                    _initTour();
                    _tourController.start();
                  },
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Replay Tour'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Task list
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isFirstTask = index == 0;
                  
                  return Card(
                    key: isFirstTask ? _taskCardKey : null,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Checkbox(
                        key: isFirstTask ? _checkboxKey : null,
                        value: task['done'],
                        onChanged: (value) {
                          setState(() {
                            _tasks[index]['done'] = value;
                          });
                        },
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['done'] 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: task['done'] 
                              ? Colors.grey 
                              : Colors.white,
                        ),
                      ),
                      trailing: Container(
                        key: isFirstTask ? _priorityBadgeKey : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task['priority'])
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPriorityColor(task['priority']),
                          ),
                        ),
                        child: Text(
                          task['priority'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(task['priority']),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _addTaskKey,
        onPressed: () {},
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
