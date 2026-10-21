import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board_column.dart';
import '../models/task_model.dart';
import '../providers/kanban_board_provider.dart';
import 'column_dialog.dart';
import 'create_task_dialog.dart';
import 'task_card_widget.dart';
import 'task_detail_modal.dart';

class BoardColumnWidget extends StatefulWidget {
  final BoardColumn column;

  const BoardColumnWidget({
    super.key,
    required this.column,
  });

  @override
  State<BoardColumnWidget> createState() => _BoardColumnWidgetState();
}

class _BoardColumnWidgetState extends State<BoardColumnWidget> {
  bool _isDragHovered = false;

  void _openEditColumnDialog(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => ColumnDialog(
        columnToEdit: widget.column,
        onSave: (title, colorHex) {
          provider.updateColumn(widget.column.id, title, colorHex);
        },
      ),
    );
  }

  void _confirmDeleteColumn(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kolom?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus kolom "${widget.column.title}"?\nSemua task di kolom ini akan dipindahkan ke kolom pertama.',
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
              provider.deleteColumn(widget.column.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus Kolom'),
          ),
        ],
      ),
    );
  }

  void _openCreateTaskDialog(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => CreateTaskDialog(
        columns: provider.columns,
        initialColumnId: widget.column.id,
        onTaskCreated: (newTask) {
          provider.addTask(newTask);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<KanbanBoardProvider>();

    final tasks = provider.getTasksForColumn(widget.column.id);
    final allColumnTasks = provider.getAllTasksForColumn(widget.column.id);

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDragHovered
              ? widget.column.color
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
          width: _isDragHovered ? 2 : 1,
        ),
      ),
      child: DragTarget<TaskModel>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isDragHovered = true;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            _isDragHovered = false;
          });
        },
        onAcceptWithDetails: (details) {
          setState(() {
            _isDragHovered = false;
          });
          final droppedTask = details.data;
          // Move to this column at the bottom
          provider.moveTask(droppedTask.id, widget.column.id, tasks.length);
        },
        builder: (context, candidateData, rejectedData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Color bar indicator
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: widget.column.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Title
                    Expanded(
                      child: Text(
                        widget.column.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[200] : const Color(0xFF172B4D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFDFE1E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allColumnTasks.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[300] : const Color(0xFF42526E),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Add task button
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      splashRadius: 18,
                      tooltip: 'Tambah Task di Kolom Ini',
                      onPressed: () => _openCreateTaskDialog(context, provider),
                    ),

                    // Column actions menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, size: 20),
                      splashRadius: 18,
                      tooltip: 'Opsi Kolom',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _openEditColumnDialog(context, provider);
                        } else if (val == 'delete') {
                          _confirmDeleteColumn(context, provider);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Kolom'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Hapus Kolom',
                                  style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Task List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 36,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.hasActiveFilter
                                    ? 'Tidak ada task sesuai filter'
                                    : 'Belum ada task di kolom ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          // Slot drop target for precision ordering
                          return DragTarget<TaskModel>(
                            onWillAcceptWithDetails: (details) =>
                                details.data.id != task.id,
                            onAcceptWithDetails: (details) {
                              provider.moveTask(
                                details.data.id,
                                widget.column.id,
                                index,
                              );
                            },
                            builder: (context, candidateSlotData, _) {
                              final isSlotHovered = candidateSlotData.isNotEmpty;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSlotHovered)
                                    Container(
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.column.color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  _buildDraggableTask(
                                    context,
                                    task,
                                    provider,
                                    isDark,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
              ),

              // Bottom Quick Add Button
              InkWell(
                onTap: () => _openCreateTaskDialog(context, provider),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buat Task Baru',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableTask(
    BuildContext context,
    TaskModel task,
    KanbanBoardProvider provider,
    bool isDark,
  ) {
    final taskCard = TaskCardWidget(
      task: task,
      onTap: () => TaskDetailModal.show(context, task),
    );

    // Draggable feedback with subtle tilt and shadow
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.03,
        child: SizedBox(
          width: 300,
          child: Opacity(
            opacity: 0.92,
            child: TaskCardWidget(
              task: task,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    // When dragging, leave a dashed placeholder
    final placeholderWidget = Opacity(
      opacity: 0.35,
      child: taskCard,
    );

    // On mobile touch, LongPressDraggable is standard to allow scrolling.
    // On desktop/web, Draggable or LongPressDraggable with short delay can be used.
    // Using LongPressDraggable with 200ms delay provides the most seamless experience across all platforms.
    return LongPressDraggable<TaskModel>(
      data: task,
      delay: kIsWeb ? const Duration(milliseconds: 150) : const Duration(milliseconds: 200),
      feedback: feedbackWidget,
      childWhenDragging: placeholderWidget,
      child: taskCard,
    );
  }
}
