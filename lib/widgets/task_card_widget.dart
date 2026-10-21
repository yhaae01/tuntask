import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
  });

  Color _getAssigneeColor(String name) {
    final colors = [
      const Color(0xFF0052CC),
      const Color(0xFF00875A),
      const Color(0xFF6554C0),
      const Color(0xFFFF5630),
      const Color(0xFFFF8B00),
      const Color(0xFF00B8D9),
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.blue.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Priority Chip & Due Date / Overdue
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPriorityChip(task.priority),
                  const Spacer(),
                  if (task.dueDate != null) _buildDueDateChip(task.dueDate!, task.isOverdue),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),

              // Description preview if available
              if (task.description.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],

              // Labels
              if (task.labels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.labels.map((label) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.blueGrey[200] : const Color(0xFF475569),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Subtasks Progress Bar & Count
              if (task.totalSubtasksCount > 0) ...[
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 14,
                          color: task.completedSubtasksCount == task.totalSubtasksCount
                              ? const Color(0xFF36B37E)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.completedSubtasksCount}/${task.totalSubtasksCount} subtasks',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: task.completedSubtasksCount == task.totalSubtasksCount
                                ? const Color(0xFF36B37E)
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: task.subtaskProgress,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.completedSubtasksCount == task.totalSubtasksCount
                              ? const Color(0xFF36B37E)
                              : const Color(0xFF0052CC),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // Footer: Task ID or Creation & Assignee Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_outline_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.id.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (task.assignee != null && task.assignee!.trim().isNotEmpty)
                    Tooltip(
                      message: 'Assignee: ${task.assignee}',
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: _getAssigneeColor(task.assignee!),
                        child: Text(
                          _getInitials(task.assignee!),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Tooltip(
                      message: 'Unassigned',
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: priority.color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: 12,
            color: priority.color,
          ),
          const SizedBox(width: 3),
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateChip(DateTime date, bool isOverdue) {
    final formatted = DateFormat('d MMM').format(date);
    final color = isOverdue ? const Color(0xFFE53935) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFFCDD2) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
