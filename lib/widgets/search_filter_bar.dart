import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_priority.dart';
import '../providers/kanban_board_provider.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<KanbanBoardProvider>();
    _searchController = TextEditingController(text: provider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<KanbanBoardProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search Field + Reset button + Metrics
          Row(
            children: [
              // Search Input Box
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      provider.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari task, deskripsi, assignee, atau label...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Reset Filter button (if active)
              if (provider.hasActiveFilter) ...[
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.resetFilter();
                  },
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                  label: const Text('Reset', style: TextStyle(fontSize: 13)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Priority Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Prioritas:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),

                // 'Semua' (All) Chip
                FilterChip(
                  label: const Text('Semua'),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: provider.selectedPriority == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: provider.selectedPriority == null
                        ? (isDark ? Colors.white : const Color(0xFF0052CC))
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                  selected: provider.selectedPriority == null,
                  onSelected: (_) {
                    provider.setPriorityFilter(null);
                  },
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  selectedColor: const Color(0xFF0052CC).withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: provider.selectedPriority == null
                          ? const Color(0xFF0052CC)
                          : Colors.transparent,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),

                // Priority specific chips
                ...TaskPriority.values.map((priority) {
                  final isSelected = provider.selectedPriority == priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Icon(
                        priority.icon,
                        size: 14,
                        color: isSelected
                            ? priority.color
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      label: Text(priority.displayName),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? priority.color
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setPriorityFilter(selected ? priority : null);
                      },
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      selectedColor: priority.color.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: isSelected ? priority.color : Colors.transparent,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
