import '../models/board_column.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';

class MockData {
  static const String colToDo = 'col-todo';
  static const String colInProgress = 'col-in-progress';
  static const String colInReview = 'col-in-review';
  static const String colDone = 'col-done';

  static List<BoardColumn> get initialColumns => [
        const BoardColumn(
          id: colToDo,
          title: 'To Do',
          colorHex: '#4A6572',
          order: 0,
        ),
        const BoardColumn(
          id: colInProgress,
          title: 'In Progress',
          colorHex: '#0052CC',
          order: 1,
        ),
        const BoardColumn(
          id: colInReview,
          title: 'In Review',
          colorHex: '#FFAB00',
          order: 2,
        ),
        const BoardColumn(
          id: colDone,
          title: 'Done',
          colorHex: '#36B37E',
          order: 3,
        ),
      ];

  static List<TaskModel> get initialTasks {
    final now = DateTime.now();

    return [
      TaskModel(
        id: 'task-101',
        title: 'KAN-101: Implement OAuth 2.0 & Apple Sign-In',
        description:
            'Implement secure authentication flow supporting Google, Apple, and Email/Password with refresh token rotation and biometric fallback.',
        columnId: colToDo,
        priority: TaskPriority.urgent,
        labels: ['Auth', 'Security', 'Backend'],
        assignee: 'Budi Santoso',
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-1',
            title: 'Configure Firebase Auth & OAuth clients',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-2',
            title: 'Implement PKCE flow for web platform',
            isCompleted: false,
          ),
          SubTaskModel(
            id: 'sub-3',
            title: 'Write automated unit tests for auth repository',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'task-102',
        title: 'KAN-102: Polish Kanban Board Drag & Drop UX',
        description:
            'Refine smooth drag gestures, elevation shadows, haptic feedback, and responsive layout for desktop, tablet, and mobile screens.',
        columnId: colInProgress,
        priority: TaskPriority.high,
        labels: ['UI/UX', 'Frontend', 'Animation'],
        assignee: 'Siti Rahma',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 4)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-4',
            title: 'Implement native DragTarget & Draggable listener',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-5',
            title: 'Add visual drop zone indicator during dragging',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-6',
            title: 'Verify horizontal scrolling behavior on trackpad',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'task-103',
        title: 'KAN-103: Automated CI/CD GitHub Actions Pipeline',
        description:
            'Create workflow to run flutter analyze, test suites, and deploy staging build artifacts automatically on PR merge to main.',
        columnId: colInReview,
        priority: TaskPriority.medium,
        labels: ['DevOps', 'CI/CD'],
        assignee: 'Rian Pratama',
        dueDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-7',
            title: 'Write GitHub workflow YAML configuration',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-8',
            title: 'Setup code coverage badge with lcov report',
            isCompleted: true,
          ),
        ],
      ),
      TaskModel(
        id: 'task-104',
        title: 'KAN-104: Fix State Sync Glitch in Offline Mode',
        description:
            'Resolve edge case where optimistic UI updates do not revert cleanly when network connectivity drops during reorder operations.',
        columnId: colToDo,
        priority: TaskPriority.high,
        labels: ['Bug', 'State Management'],
        assignee: 'Budi Santoso',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-9',
            title: 'Reproduce state mismatch with network throttle',
            isCompleted: false,
          ),
          SubTaskModel(
            id: 'sub-10',
            title: 'Add retry queue and rollback mechanism',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'task-105',
        title: 'KAN-105: Design System Typography & Dark Palette',
        description:
            'Define tokenized colors, elevations, card borders, and responsive font scale following Jira & Atlassian design guidelines.',
        columnId: colDone,
        priority: TaskPriority.low,
        labels: ['Design', 'Theme'],
        assignee: 'Maya Putri',
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 7)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-11',
            title: 'Create semantic color tokens',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-12',
            title: 'Document component variants in Figma',
            isCompleted: true,
          ),
        ],
      ),
      TaskModel(
        id: 'task-106',
        title: 'KAN-106: Conduct Security & Dependency Audit',
        description:
            'Audit all third-party dependencies for known CVEs, evaluate license compliance, and configure automated vulnerability alerts.',
        columnId: colInReview,
        priority: TaskPriority.urgent,
        labels: ['Security', 'Compliance'],
        assignee: 'Maya Putri',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 3)),
        subtasks: const [
          SubTaskModel(
            id: 'sub-13',
            title: 'Run snyk and flutter pub outdated scan',
            isCompleted: true,
          ),
          SubTaskModel(
            id: 'sub-14',
            title: 'Document remediations in audit log',
            isCompleted: false,
          ),
        ],
      ),
    ];
  }
}
