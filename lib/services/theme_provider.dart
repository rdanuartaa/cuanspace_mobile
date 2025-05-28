import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kelas untuk mengelola tema aplikasi (light/dark mode) dan menyimpan preferensi ke SharedPreferences.
class ThemeProvider with ChangeNotifier {
  /// Menyimpan status tema (true untuk dark mode, false untuk light mode).
  bool _isDarkMode = false;

  /// Menyimpan mode tema yang digunakan oleh MaterialApp.
  ThemeMode _themeMode = ThemeMode.light;

  /// Getter untuk mendapatkan status dark mode.
  bool get isDarkMode => _isDarkMode;

  /// Getter untuk mendapatkan mode tema.
  ThemeMode get themeMode => _themeMode;

  /// Konstruktor yang memuat tema saat inisialisasi.
  ThemeProvider() {
    _loadTheme();
  }

  /// Memuat preferensi tema dari SharedPreferences.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Mengubah tema dan menyimpan preferensi ke SharedPreferences.
  Future<void> toggleTheme(bool isDark) async {
    try {
      _isDarkMode = isDark;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
