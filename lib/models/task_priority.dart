import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF78909C); // Slate Grey
      case TaskPriority.medium:
        return const Color(0xFF1E88E5); // Jira Blue
      case TaskPriority.high:
        return const Color(0xFFFB8C00); // Warm Orange
      case TaskPriority.urgent:
        return const Color(0xFFE53935); // Critical Red
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
      case TaskPriority.urgent:
        return Icons.keyboard_double_arrow_up_rounded;
    }
  }

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}
