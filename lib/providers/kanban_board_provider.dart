import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/mock_data.dart';
import '../models/board_column.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';

class KanbanBoardProvider extends ChangeNotifier {
  static const String _prefTasksKey = 'tuntask_saved_tasks';
  static const String _prefColumnsKey = 'tuntask_saved_columns';

  final _uuid = const Uuid();

  List<BoardColumn> _columns = [];
  List<TaskModel> _tasks = [];

  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  bool _isLoaded = false;

  KanbanBoardProvider() {
    _initializeData();
  }

  bool get isLoaded => _isLoaded;

  Future<void> _initializeData() async {
    _columns = List.from(MockData.initialColumns);
    _tasks = List.from(MockData.initialTasks);
    await _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final columnsJson = prefs.getString(_prefColumnsKey);
      if (columnsJson != null) {
        final List<dynamic> decodedCols = json.decode(columnsJson);
        _columns = decodedCols
            .map((item) => BoardColumn.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      final tasksJson = prefs.getString(_prefTasksKey);
      if (tasksJson != null) {
        final List<dynamic> decodedTasks = json.decode(tasksJson);
        _tasks = decodedTasks
            .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      // If initial launch without existing saved data, persist initial mock data
      if (columnsJson == null && tasksJson == null) {
        await _saveAll();
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading kanban board data: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksMapList = _tasks.map((t) => t.toMap()).toList();
      await prefs.setString(_prefTasksKey, json.encode(tasksMapList));
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> _saveColumns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final columnsMapList = _columns.map((c) => c.toMap()).toList();
      await prefs.setString(_prefColumnsKey, json.encode(columnsMapList));
    } catch (e) {
      debugPrint('Error saving columns: $e');
    }
  }

  Future<void> _saveAll() async {
    await Future.wait([_saveColumns(), _saveTasks()]);
  }

  Future<void> resetToMockData() async {
    _columns = List.from(MockData.initialColumns);
    _tasks = List.from(MockData.initialTasks);
    notifyListeners();
    await _saveAll();
  }

  // Getters
  List<BoardColumn> get columns {
    final sorted = List<BoardColumn>.from(_columns);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(sorted);
  }

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);

  String get searchQuery => _searchQuery;
  TaskPriority? get selectedPriority => _selectedPriority;

  bool get hasActiveFilter =>
      _searchQuery.isNotEmpty || _selectedPriority != null;

  int get totalTasksCount => _tasks.length;
  int get completedTasksCount {
    final doneCol = _columns.firstWhere(
      (c) => c.title.toLowerCase().contains('done'),
      orElse: () => _columns.isNotEmpty ? _columns.last : const BoardColumn(id: '', title: '', colorHex: '', order: 0),
    );
    if (doneCol.id.isEmpty) return 0;
    return _tasks.where((t) => t.columnId == doneCol.id).length;
  }

  // Filter Tasks for a Column
  List<TaskModel> getTasksForColumn(String columnId) {
    return _tasks.where((task) {
      if (task.columnId != columnId) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        final matchesAssignee =
            task.assignee?.toLowerCase().contains(query) ?? false;
        final matchesLabel =
            task.labels.any((l) => l.toLowerCase().contains(query));

        if (!matchesTitle && !matchesDesc && !matchesAssignee && !matchesLabel) {
          return false;
        }
      }

      // Filter by priority
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      return true;
    }).toList();
  }

  // All tasks in a column (unfiltered, for accurate counts)
  List<TaskModel> getAllTasksForColumn(String columnId) {
    return _tasks.where((t) => t.columnId == columnId).toList();
  }

  // Search & Filter
  void filterTasks(String searchQuery, TaskPriority? priority) {
    _searchQuery = searchQuery.trim();
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void resetFilter() {
    _searchQuery = '';
    _selectedPriority = null;
    notifyListeners();
  }

  // Task Operations
  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
    _saveTasks();
  }

  void updateTask(TaskModel updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      _saveTasks();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    _saveTasks();
  }

  void moveTask(String taskId, String targetColumnId, int newIndex) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final currentTask = _tasks[taskIndex];
    final updatedTask = currentTask.copyWith(columnId: targetColumnId);

    // Remove task from list
    _tasks.removeAt(taskIndex);

    // Find the tasks currently belonging to targetColumnId
    final targetTasksIndices = <int>[];
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].columnId == targetColumnId) {
        targetTasksIndices.add(i);
      }
    }

    if (targetTasksIndices.isEmpty || newIndex <= 0) {
      // Insert at the front of target column tasks, or at start of list
      final insertionPoint =
          targetTasksIndices.isNotEmpty ? targetTasksIndices.first : _tasks.length;
      _tasks.insert(insertionPoint, updatedTask);
    } else if (newIndex >= targetTasksIndices.length) {
      // Insert after the last item of the target column
      final insertionPoint = targetTasksIndices.last + 1;
      _tasks.insert(insertionPoint, updatedTask);
    } else {
      // Insert at the specific index within target column
      final insertionPoint = targetTasksIndices[newIndex];
      _tasks.insert(insertionPoint, updatedTask);
    }

    notifyListeners();
    _saveTasks();
  }

  void toggleSubtask(String taskId, String subtaskId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final updatedSubtasks = task.subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
    notifyListeners();
    _saveTasks();
  }

  void addSubtask(String taskId, String title) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1 || title.trim().isEmpty) return;

    final task = _tasks[taskIndex];
    final newSubtask = SubTaskModel(
      id: 'sub-${_uuid.v4().substring(0, 8)}',
      title: title.trim(),
      isCompleted: false,
    );

    _tasks[taskIndex] = task.copyWith(
      subtasks: [...task.subtasks, newSubtask],
    );
    notifyListeners();
    _saveTasks();
  }

  void deleteSubtask(String taskId, String subtaskId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    _tasks[taskIndex] = task.copyWith(
      subtasks: task.subtasks.where((s) => s.id != subtaskId).toList(),
    );
    notifyListeners();
    _saveTasks();
  }

  // Column Operations
  void addColumn(String title, String colorHex) {
    if (title.trim().isEmpty) return;

    final newColumn = BoardColumn(
      id: 'col-${_uuid.v4().substring(0, 8)}',
      title: title.trim(),
      colorHex: colorHex.startsWith('#') ? colorHex : '#$colorHex',
      order: _columns.length,
    );

    _columns.add(newColumn);
    notifyListeners();
    _saveColumns();
  }

  void updateColumn(String columnId, String newTitle, String colorHex) {
    final index = _columns.indexWhere((c) => c.id == columnId);
    if (index != -1) {
      _columns[index] = _columns[index].copyWith(
        title: newTitle.trim(),
        colorHex: colorHex.startsWith('#') ? colorHex : '#$colorHex',
      );
      notifyListeners();
      _saveColumns();
    }
  }

  void deleteColumn(String columnId) {
    final colIndex = _columns.indexWhere((c) => c.id == columnId);
    if (colIndex == -1) return;

    _columns.removeAt(colIndex);

    // Re-index remaining column orders
    for (int i = 0; i < _columns.length; i++) {
      _columns[i] = _columns[i].copyWith(order: i);
    }

    if (_columns.isNotEmpty) {
      // Move tasks from deleted column to the default first column
      final fallbackColumnId = _columns.first.id;
      _tasks = _tasks.map((task) {
        if (task.columnId == columnId) {
          return task.copyWith(columnId: fallbackColumnId);
        }
        return task;
      }).toList();
    } else {
      // If no columns remain, clear all tasks
      _tasks.clear();
    }

    notifyListeners();
    _saveAll();
  }

  void reorderColumn(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _columns.removeAt(oldIndex);
    _columns.insert(newIndex, item);

    for (int i = 0; i < _columns.length; i++) {
      _columns[i] = _columns[i].copyWith(order: i);
    }
    notifyListeners();
    _saveColumns();
  }
}
