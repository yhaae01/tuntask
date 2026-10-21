import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/board_column.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';
import '../providers/kanban_board_provider.dart';

class TaskDetailModal extends StatefulWidget {
  final TaskModel initialTask;

  const TaskDetailModal({
    super.key,
    required this.initialTask,
  });

  static Future<void> show(BuildContext context, TaskModel task) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailModal(initialTask: task),
    );
  }

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _assigneeController;
  late TextEditingController _newSubtaskController;

  late String _currentColumnId;
  late TaskPriority _currentPriority;
  DateTime? _currentDueDate;
  bool _isEditingDetails = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask.title);
    _descController = TextEditingController(text: widget.initialTask.description);
    _assigneeController =
        TextEditingController(text: widget.initialTask.assignee ?? '');
    _newSubtaskController = TextEditingController();

    _currentColumnId = widget.initialTask.columnId;
    _currentPriority = widget.initialTask.priority;
    _currentDueDate = widget.initialTask.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assigneeController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _saveTaskChanges(KanbanBoardProvider provider, TaskModel currentTask) {
    final updated = currentTask.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      columnId: _currentColumnId,
      priority: _currentPriority,
      assignee: _assigneeController.text.trim().isEmpty
          ? null
          : _assigneeController.text.trim(),
      dueDate: _currentDueDate,
    );
    provider.updateTask(updated);
    setState(() {
      _isEditingDetails = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan task berhasil disimpan'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Task?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${widget.initialTask.title}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.deleteTask(widget.initialTask.id);
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task berhasil dihapus'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDueDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _currentDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<KanbanBoardProvider>();

    // Fetch latest instance of task from provider
    final currentTask = provider.allTasks.firstWhere(
      (t) => t.id == widget.initialTask.id,
      orElse: () => widget.initialTask,
    );

    final columns = provider.columns;
    final activeColumn = columns.firstWhere(
      (c) => c.id == _currentColumnId,
      orElse: () => columns.isNotEmpty
          ? columns.first
          : const BoardColumn(id: '', title: 'Unknown', colorHex: '#0052CC', order: 0),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052CC).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bookmark_rounded,
                            size: 14,
                            color: Color(0xFF0052CC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentTask.id.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0052CC),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: _isEditingDetails ? 'Mode Lihat' : 'Mode Edit',
                      icon: Icon(
                        _isEditingDetails
                            ? Icons.visibility_outlined
                            : Icons.edit_outlined,
                        color: const Color(0xFF0052CC),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditingDetails = !_isEditingDetails;
                        });
                      },
                    ),
                    IconButton(
                      tooltip: 'Hapus Task',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE53935),
                      ),
                      onPressed: () => _confirmDeleteTask(context, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Title section
                    if (_isEditingDetails) ...[
                      const Text(
                        'Judul Task',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        currentTask.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Quick Meta Controls (Column Status & Priority)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Column Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: activeColumn.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: activeColumn.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentColumnId,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: columns.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: c.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        c.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: c.color,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newCol) {
                                if (newCol != null) {
                                  setState(() {
                                    _currentColumnId = newCol;
                                  });
                                  provider.moveTask(currentTask.id, newCol, 0);
                                }
                              },
                            ),
                          ),
                        ),

                        // Priority Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _currentPriority.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _currentPriority.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskPriority>(
                              value: _currentPriority,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: TaskPriority.values.map((p) {
                                return DropdownMenuItem<TaskPriority>(
                                  value: p,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(p.icon, size: 16, color: p.color),
                                      const SizedBox(width: 6),
                                      Text(
                                        p.displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: p.color,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newP) {
                                if (newP != null) {
                                  setState(() {
                                    _currentPriority = newP;
                                  });
                                  provider.updateTask(
                                    currentTask.copyWith(priority: newP),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        // Due date picker badge
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentTask.isOverdue
                                    ? const Color(0xFFE53935)
                                    : (isDark ? Colors.white12 : Colors.black12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                  color: currentTask.isOverdue
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF0052CC),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentDueDate != null
                                      ? DateFormat('d MMM yyyy')
                                          .format(_currentDueDate!)
                                      : 'Set Due Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: currentTask.isOverdue
                                        ? const Color(0xFFE53935)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Assignee
                    const Text(
                      'Assignee',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    if (_isEditingDetails) ...[
                      TextField(
                        controller: _assigneeController,
                        decoration: InputDecoration(
                          hintText: 'Nama assignee...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF0052CC),
                            child: Text(
                              (currentTask.assignee?.isNotEmpty ?? false)
                                  ? currentTask.assignee![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            currentTask.assignee ?? 'Belum ada assignee (Unassigned)',
                            style: TextStyle(
                              fontSize: 14,
                              color: currentTask.assignee == null
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Description Section
                    const Text(
                      'Deskripsi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    if (_isEditingDetails) ...[
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Deskripsi lengkap tugas...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              _saveTaskChanges(provider, currentTask),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Simpan Perubahan Teks'),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Text(
                          currentTask.description.trim().isNotEmpty
                              ? currentTask.description
                              : 'Tidak ada deskripsi rinci untuk task ini.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: currentTask.description.trim().isEmpty
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ],

                    // Labels
                    if (currentTask.labels.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Labels',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: currentTask.labels.map((lbl) {
                          return Chip(
                            label: Text(
                              lbl,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Subtasks Section
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist_rounded,
                          size: 20,
                          color: Color(0xFF0052CC),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Subtasks (${currentTask.completedSubtasksCount}/${currentTask.totalSubtasksCount})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (currentTask.totalSubtasksCount > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: currentTask.subtaskProgress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            currentTask.completedSubtasksCount ==
                                    currentTask.totalSubtasksCount
                                ? const Color(0xFF36B37E)
                                : const Color(0xFF0052CC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Subtasks List
                    if (currentTask.subtasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Belum ada subtask. Tambahkan subtask baru di bawah.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentTask.subtasks.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final subtask = currentTask.subtasks[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Checkbox(
                                activeColor: const Color(0xFF36B37E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                value: subtask.isCompleted,
                                onChanged: (_) {
                                  provider.toggleSubtask(
                                    currentTask.id,
                                    subtask.id,
                                  );
                                },
                              ),
                              title: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: subtask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: subtask.isCompleted
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  provider.deleteSubtask(
                                    currentTask.id,
                                    subtask.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Add new subtask input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSubtaskController,
                            decoration: InputDecoration(
                              hintText: 'Tambah subtask baru...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                provider.addSubtask(currentTask.id, val);
                                _newSubtaskController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final text = _newSubtaskController.text.trim();
                            if (text.isNotEmpty) {
                              provider.addSubtask(currentTask.id, text);
                              _newSubtaskController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
