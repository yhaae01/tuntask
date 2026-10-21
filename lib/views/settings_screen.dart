import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> showModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pengaturan & Tema',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildThemeModeSection(context, isDark),
              const SizedBox(height: 24),
              _buildPaletteSection(context, isDark),
              const SizedBox(height: 24),
              _buildLivePreviewCard(context, isDark),
              const SizedBox(height: 28),
              _buildResetButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildThemeModeSection(BuildContext context, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;
    final primaryColor = themeProvider.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: primaryColor, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Mode Tampilan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih preferensi tema terang, gelap, atau menyesuaikan sistem perangkat.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('Sistem'),
                    icon: Icon(Icons.brightness_auto_rounded, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Terang'),
                    icon: Icon(Icons.light_mode_rounded, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Gelap'),
                    icon: Icon(Icons.dark_mode_rounded, size: 18),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  themeProvider.setThemeMode(newSelection.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPaletteSection(BuildContext context, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final selectedColor = themeProvider.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.color_lens_outlined, color: selectedColor, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Warna Aksen Utama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih warna tema yang akan diterapkan ke tombol, header, indikator, dan highlight board.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.availablePalettes.map((palette) {
                final isSelected = selectedColor.toARGB32() == palette.color.toARGB32();

                return InkWell(
                  onTap: () => themeProvider.setPrimaryColor(palette.color),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.color.withValues(alpha: 0.12)
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? palette.color
                            : Colors.transparent,
                        width: 1.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: palette.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: palette.color.withValues(alpha: 0.35),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          palette.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? palette.color
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLivePreviewCard(BuildContext context, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.remove_red_eye_outlined,
                    color: primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pratinjau Tema (Live Preview)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'KAN-201',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 30),
                        ),
                        onPressed: () {},
                        child: const Text('Aksi Tombol',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Preview Kartu Task Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Warna aksen dan latar belakang menyesuaikan pilihan tema secara langsung.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildResetButton(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Center(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE53935),
          side: const BorderSide(color: Color(0xFFE53935), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          themeProvider.resetToDefault();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tema berhasil direset ke pengaturan default (Jira Blue & Sistem)'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.restart_alt_rounded, size: 18),
        label: const Text(
          'Reset ke Tema Default',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SettingsModalSheet extends StatelessWidget {
  const SettingsModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F5F7),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Pengaturan & Tema',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    SettingsScreen._buildThemeModeSection(context, isDark),
                    const SizedBox(height: 20),
                    SettingsScreen._buildPaletteSection(context, isDark),
                    const SizedBox(height: 20),
                    SettingsScreen._buildLivePreviewCard(context, isDark),
                    const SizedBox(height: 24),
                    SettingsScreen._buildResetButton(context),
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
