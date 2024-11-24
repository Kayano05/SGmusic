import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static ThemeService? _instance;
  
  static final List<ThemeData> themes = [
    // 默认主题：深邃夜空
    ThemeData(
      primaryColor: const Color(0xFF6B8CFF),
      scaffoldBackgroundColor: const Color(0xFF1A1B2E),
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6B8CFF),
        secondary: Color(0xFF2E325C),
        surface: Color(0xFF1A1B2E),
        background: Color(0xFF1A1B2E),
      ),
      cardColor: const Color(0xFF2E325C),
      dividerColor: const Color(0xFF3D4163),
    ),
    
    // 森林晨露
    ThemeData(
      primaryColor: const Color(0xFF7BCEA0),
      scaffoldBackgroundColor: const Color(0xFF1C2827),
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7BCEA0),
        secondary: Color(0xFF2C4A3F),
        surface: Color(0xFF1C2827),
        background: Color(0xFF1C2827),
      ),
      cardColor: const Color(0xFF2C4A3F),
      dividerColor: const Color(0xFF3D5A4F),
    ),
    
    // 紫罗兰黄昏
    ThemeData(
      primaryColor: const Color(0xFFB784E0),
      scaffoldBackgroundColor: const Color(0xFF251E2C),
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFB784E0),
        secondary: Color(0xFF4A3960),
        surface: Color(0xFF251E2C),
        background: Color(0xFF251E2C),
      ),
      cardColor: const Color(0xFF4A3960),
      dividerColor: const Color(0xFF5A4970),
    ),
  ];

  static final List<String> themeNames = [
    '深邃夜空',
    '森林晨露',
    '紫罗兰黄昏',
  ];

  int _currentThemeIndex = 0;
  
  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  ThemeService._();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeIndex = prefs.getInt(_themeKey) ?? 0;
    notifyListeners();
  }

  ThemeData get currentTheme => themes[_currentThemeIndex];
  int get currentThemeIndex => _currentThemeIndex;

  Future<void> setTheme(int index) async {
    if (index < 0 || index >= themes.length) return;
    _currentThemeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, index);
    notifyListeners();
  }
} 