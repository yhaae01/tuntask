import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kanban_board_provider.dart';
import '../widgets/board_column_widget.dart';
import '../widgets/column_dialog.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/search_filter_bar.dart';
import 'settings_screen.dart';

class KanbanBoardView extends StatelessWidget {
  const KanbanBoardView({super.key});

  void _openAddColumnDialog(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => ColumnDialog(
        onSave: (title, colorHex) {
          provider.addColumn(title, colorHex);
        },
      ),
    );
  }

  void _openCreateTaskDialog(BuildContext context, KanbanBoardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => CreateTaskDialog(
        columns: provider.columns,
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
    final primaryColor = theme.colorScheme.primary;
    final provider = context.watch<KanbanBoardProvider>();
    final columns = provider.columns;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.view_kanban_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TunTask Kanban',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Jira-Style Agile Sprint Board',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Stat chips
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: Color(0xFF36B37E),
                ),
                const SizedBox(width: 4),
                Text(
                  '${provider.completedTasksCount}/${provider.totalTasksCount} Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Add Task Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _openCreateTaskDialog(context, provider),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Task Baru',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Settings Button
          IconButton(
            tooltip: 'Pengaturan & Tema',
            icon: const Icon(Icons.palette_outlined, size: 22),
            onPressed: () => SettingsScreen.showModal(context),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          const SearchFilterBar(),

          // Board Canvas (Horizontal Scroll)
          Expanded(
            child: columns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dashboard_customize_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada kolom di board ini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _openAddColumnDialog(context, provider),
                          icon: const Icon(Icons.add),
                          label: const Text('Buat Kolom Pertama'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Kanban Columns
                        ...columns.map((col) {
                          return BoardColumnWidget(
                            key: ValueKey(col.id),
                            column: col,
                          );
                        }),

                        // "Tambah Kolom Baru" Button Card at far right
                        _buildAddColumnButton(context, provider, isDark),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddColumnButton(
    BuildContext context,
    KanbanBoardProvider provider,
    bool isDark,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 20),
      child: InkWell(
        onTap: () => _openAddColumnDialog(context, provider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.12),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: isDark ? primaryColor : primaryColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Tambah Kolom Baru',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
