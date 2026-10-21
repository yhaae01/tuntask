import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/board_column.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';

class CreateTaskDialog extends StatefulWidget {
  final List<BoardColumn> columns;
  final String? initialColumnId;
  final Function(TaskModel newTask) onTaskCreated;

  const CreateTaskDialog({
    super.key,
    required this.columns,
    this.initialColumnId,
    required this.onTaskCreated,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _assigneeController;
  late TextEditingController _labelsController;
  late TextEditingController _subtaskInputController;

  late String _selectedColumnId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  final List<String> _initialSubtaskTitles = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _assigneeController = TextEditingController();
    _labelsController = TextEditingController();
    _subtaskInputController = TextEditingController();

    if (widget.initialColumnId != null &&
        widget.columns.any((c) => c.id == widget.initialColumnId)) {
      _selectedColumnId = widget.initialColumnId!;
    } else {
      _selectedColumnId =
          widget.columns.isNotEmpty ? widget.columns.first.id : '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assigneeController.dispose();
    _labelsController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtaskDraft() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _initialSubtaskTitles.add(text);
        _subtaskInputController.clear();
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final labels = _labelsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final subtasks = _initialSubtaskTitles
        .map((title) => SubTaskModel(
              id: 'sub-${_uuid.v4().substring(0, 8)}',
              title: title,
              isCompleted: false,
            ))
        .toList();

    final randomIdNumber = 100 + (DateTime.now().millisecondsSinceEpoch % 900);
    final taskId = 'task-$randomIdNumber';

    final newTask = TaskModel(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      columnId: _selectedColumnId,
      priority: _selectedPriority,
      labels: labels,
      assignee: _assigneeController.text.trim().isEmpty
          ? null
          : _assigneeController.text.trim(),
      dueDate: _selectedDueDate,
      createdAt: DateTime.now(),
      subtasks: subtasks,
    );

    widget.onTaskCreated(newTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052CC).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: Color(0xFF0052CC),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Buat Task Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    splashRadius: 20,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Judul Task *',
                            hintText: 'Misal: KAN-107: Implement Dark Mode Toggle',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.assignment_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Judul task wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Column and Priority Rows
                        Row(
                          children: [
                            // Column selector
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedColumnId.isNotEmpty
                                    ? _selectedColumnId
                                    : null,
                                decoration: InputDecoration(
                                  labelText: 'Status / Kolom',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.view_column_outlined),
                                ),
                                items: widget.columns.map((col) {
                                  return DropdownMenuItem<String>(
                                    value: col.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: col.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(col.title),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedColumnId = val;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Priority selector
                            Expanded(
                              child: DropdownButtonFormField<TaskPriority>(
                                initialValue: _selectedPriority,
                                decoration: InputDecoration(
                                  labelText: 'Prioritas',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(
                                    _selectedPriority.icon,
                                    color: _selectedPriority.color,
                                  ),
                                ),
                                items: TaskPriority.values.map((p) {
                                  return DropdownMenuItem<TaskPriority>(
                                    value: p,
                                    child: Row(
                                      children: [
                                        Icon(p.icon, size: 16, color: p.color),
                                        const SizedBox(width: 6),
                                        Text(
                                          p.displayName,
                                          style: TextStyle(
                                            color: p.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedPriority = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi',
                            hintText: 'Detail tugas, acceptance criteria, atau catatan...',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Icon(Icons.description_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Assignee and Due Date
                        Row(
                          children: [
                            // Assignee
                            Expanded(
                              child: TextFormField(
                                controller: _assigneeController,
                                decoration: InputDecoration(
                                  labelText: 'Assignee',
                                  hintText: 'Nama PIC (contoh: Budi)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Due Date Button
                            Expanded(
                              child: InkWell(
                                onTap: _pickDueDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black.withValues(alpha: 0.25),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: Color(0xFF0052CC),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedDueDate != null
                                              ? DateFormat('d MMM yyyy')
                                                  .format(_selectedDueDate!)
                                              : 'Pilih Due Date',
                                          style: TextStyle(
                                            color: _selectedDueDate != null
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (_selectedDueDate != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDueDate = null;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.clear_rounded,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Labels
                        TextFormField(
                          controller: _labelsController,
                          decoration: InputDecoration(
                            labelText: 'Labels (pisahkan dengan koma)',
                            hintText: 'Frontend, Bug, HighPriority',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Subtasks Section
                        const Text(
                          'Subtasks (Opsional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _subtaskInputController,
                                decoration: InputDecoration(
                                  hintText: 'Ketik subtask lalu klik tombol Tambah',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onSubmitted: (_) => _addSubtaskDraft(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                foregroundColor: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _addSubtaskDraft,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah'),
                            ),
                          ],
                        ),

                        if (_initialSubtaskTitles.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _initialSubtaskTitles.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  leading: const Icon(
                                    Icons.check_box_outline_blank_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  title: Text(
                                    _initialSubtaskTitles[index],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _initialSubtaskTitles.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submit,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Simpan Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
