import 'package:flutter/material.dart';
import '../models/board_column.dart';

class ColumnDialog extends StatefulWidget {
  final BoardColumn? columnToEdit;
  final Function(String title, String colorHex) onSave;

  const ColumnDialog({
    super.key,
    this.columnToEdit,
    required this.onSave,
  });

  @override
  State<ColumnDialog> createState() => _ColumnDialogState();
}

class _ColumnDialogState extends State<ColumnDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String _selectedColorHex;

  final List<String> _presetColors = [
    '#0052CC', // Jira Blue
    '#4A6572', // Slate Navy
    '#36B37E', // Emerald Green
    '#FFAB00', // Amber Yellow
    '#FF5630', // Coral Red
    '#6554C0', // Royal Purple
    '#00B8D9', // Teal Cyan
    '#172B4D', // Deep Charcoal
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.columnToEdit?.title ?? '');
    _selectedColorHex =
        widget.columnToEdit?.colorHex.toUpperCase() ?? _presetColors.first;
    if (!_presetColors.contains(_selectedColorHex)) {
      _selectedColorHex = _presetColors.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.columnToEdit != null;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _parseHex(_selectedColorHex).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.view_column_rounded,
              color: _parseHex(_selectedColorHex),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Kolom' : 'Tambah Kolom Baru',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nama Kolom',
                  hintText: 'Misal: Testing, In QA, Backlog',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama kolom wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Warna Indikator',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetColors.map((hex) {
                  final color = _parseHex(hex);
                  final isSelected = hex == _selectedColorHex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorHex = hex;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _parseHex(_selectedColorHex),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_titleController.text.trim(), _selectedColorHex);
              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? 'Simpan Perubahan' : 'Buat Kolom'),
        ),
      ],
    );
  }
}
