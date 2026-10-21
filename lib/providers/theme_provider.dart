import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefThemeModeKey = 'tuntask_theme_mode';
  static const String _prefPrimaryColorKey = 'tuntask_primary_color';

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppTheme.defaultPrimaryColor;
  bool _isLoaded = false;

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isLoaded => _isLoaded;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load ThemeMode
      final modeStr = prefs.getString(_prefThemeModeKey);
      if (modeStr != null) {
        switch (modeStr) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      }

      // Load Primary Color
      final colorValue = prefs.getInt(_prefPrimaryColorKey);
      if (colorValue != null) {
        _primaryColor = Color(colorValue);
      }
    } catch (_) {
      // Graceful fallback to default values in case of any platform storage error
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'system';
      if (mode == ThemeMode.light) {
        modeStr = 'light';
      } else if (mode == ThemeMode.dark) {
        modeStr = 'dark';
      }
      await prefs.setString(_prefThemeModeKey, modeStr);
    } catch (_) {}
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    _primaryColor = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      // Store ARGB 32-bit int
      await prefs.setInt(_prefPrimaryColorKey, color.toARGB32());
    } catch (_) {}
  }

  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.system;
    _primaryColor = AppTheme.defaultPrimaryColor;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefThemeModeKey);
      await prefs.remove(_prefPrimaryColorKey);
    } catch (_) {}
  }
}
