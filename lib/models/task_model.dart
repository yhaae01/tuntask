import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'subtask_model.dart';
import 'task_priority.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String columnId;
  final TaskPriority priority;
  final List<String> labels;
  final String? assignee;
  final DateTime? dueDate;
  final DateTime createdAt;
  final List<SubTaskModel> subtasks;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.columnId,
    required this.priority,
    this.labels = const [],
    this.assignee,
    this.dueDate,
    required this.createdAt,
    this.subtasks = const [],
  });

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  int get totalSubtasksCount => subtasks.length;

  double get subtaskProgress =>
      totalSubtasksCount == 0 ? 0.0 : completedSubtasksCount / totalSubtasksCount;

  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? columnId,
    TaskPriority? priority,
    List<String>? labels,
    String? assignee,
    bool clearAssignee = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
    List<SubTaskModel>? subtasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      columnId: columnId ?? this.columnId,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      assignee: clearAssignee ? null : (assignee ?? this.assignee),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'columnId': columnId,
      'priority': priority.name,
      'labels': labels,
      'assignee': assignee,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((x) => x.toMap()).toList(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      columnId: map['columnId']?.toString() ?? '',
      priority: TaskPriority.fromString(map['priority']?.toString()),
      labels: (map['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      assignee: map['assignee']?.toString(),
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((x) => SubTaskModel.fromMap(Map<String, dynamic>.from(x as Map)))
              .toList() ??
          const [],
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.columnId == columnId &&
        other.priority == priority &&
        listEquals(other.labels, labels) &&
        other.assignee == assignee &&
        other.dueDate == dueDate &&
        other.createdAt == createdAt &&
        listEquals(other.subtasks, subtasks);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        columnId.hashCode ^
        priority.hashCode ^
        labels.hashCode ^
        assignee.hashCode ^
        dueDate.hashCode ^
        createdAt.hashCode ^
        subtasks.hashCode;
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, columnId: $columnId, priority: $priority, subtasks: ${subtasks.length})';
  }
}
