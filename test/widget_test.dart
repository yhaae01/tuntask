import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuntask/main.dart';
import 'package:tuntask/models/task_model.dart';
import 'package:tuntask/models/task_priority.dart';
import 'package:tuntask/providers/kanban_board_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TunTask Board smoke test', (WidgetTester tester) async {
    // Set a wide screen size typical for desktop / web kanban board
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const TunTaskApp());
    await tester.pumpAndSettle();

    // Verify app title is rendered
    expect(find.text('TunTask Kanban'), findsOneWidget);

    // Verify default columns are present
    expect(find.text('TO DO'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('IN REVIEW'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    // Verify Settings button is present in AppBar
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
  });

  test('KanbanBoardProvider persists added task across instances', () async {
    final provider1 = KanbanBoardProvider();
    // Allow initial load
    await Future.delayed(const Duration(milliseconds: 50));

    final initialCount = provider1.allTasks.length;
    final newTask = TaskModel(
      id: 'test-custom-task-1',
      title: 'Persistent Task Test',
      description: 'Testing task persistence',
      columnId: provider1.columns.first.id,
      priority: TaskPriority.high,
      createdAt: DateTime.now(),
    );

    provider1.addTask(newTask);
    expect(provider1.allTasks.length, initialCount + 1);

    // Wait for async SharedPreferences write
    await Future.delayed(const Duration(milliseconds: 100));

    // Create a new provider instance simulating app restart
    final provider2 = KanbanBoardProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    expect(provider2.allTasks.length, initialCount + 1);
    expect(provider2.allTasks.any((t) => t.id == 'test-custom-task-1'), isTrue);
    expect(
      provider2.allTasks.firstWhere((t) => t.id == 'test-custom-task-1').title,
      'Persistent Task Test',
    );
  });

  test('TaskModel copyWith clearDueDate and priority update work properly', () {
    final now = DateTime.now();
    final task = TaskModel(
      id: 'task-1',
      title: 'Task 1',
      description: 'Desc',
      columnId: 'col-1',
      priority: TaskPriority.low,
      dueDate: now,
      createdAt: now,
    );

    // Update priority and column
    final updated = task.copyWith(
      priority: TaskPriority.urgent,
      columnId: 'col-2',
    );
    expect(updated.priority, TaskPriority.urgent);
    expect(updated.columnId, 'col-2');
    expect(updated.dueDate, now);

    // Clear due date
    final cleared = updated.copyWith(clearDueDate: true);
    expect(cleared.dueDate, isNull);
  });
}
