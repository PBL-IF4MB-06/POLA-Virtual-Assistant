import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends ChangeNotifier {
  ThemeState();

  static const _key = 'pola_theme_mode_v1';
  static const _seedKey = 'pola_theme_seed_v1';

  ThemeMode _mode = ThemeMode.light;
  Color _seedColor = const Color(0xFF005FB8);

  ThemeMode get mode => _mode;
  Color get seedColor => _seedColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    switch (value) {
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      case 'system':
        _mode = ThemeMode.system;
        break;
      default:
        _mode = ThemeMode.light;
    }

    final seed = prefs.getInt(_seedKey);
    if (seed != null) {
      _seedColor = Color(seed);
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_key, value);
  }

  Future<void> setSeedColor(Color color) async {
    if (color.value == _seedColor.value) return;
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedKey, color.value);
  }
}

