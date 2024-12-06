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
        onPrimary: Colors.white,
        onSecondary: Colors.white70,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      cardColor: const Color(0xFF2E325C),
      dividerColor: const Color(0xFF3D4163),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1B2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
        onPrimary: Colors.white,
        onSecondary: Colors.white70,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      cardColor: const Color(0xFF2C4A3F),
      dividerColor: const Color(0xFF3D5A4F),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C2827),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
        onPrimary: Colors.white,
        onSecondary: Colors.white70,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      cardColor: const Color(0xFF4A3960),
      dividerColor: const Color(0xFF5A4970),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF251E2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    
    // 晨曦云霭
    ThemeData(
      primaryColor: const Color(0xFF82A0D8),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF82A0D8),
        secondary: Color(0xFFEAEFF7),
        surface: Color(0xFFF5F7FA),
        background: Color(0xFFF5F7FA),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF4A5B73),
        onSurface: Color(0xFF4A5B73),
        onBackground: Color(0xFF4A5B73),
      ),
      cardColor: const Color(0xFFEAEFF7),
      dividerColor: const Color(0xFFD8E1ED),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF4A5B73)),
        bodyMedium: TextStyle(color: Color(0xFF4A5B73)),
        titleMedium: TextStyle(color: Color(0xFF4A5B73)),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF4A5B73),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FA),
        foregroundColor: Color(0xFF4A5B73),
        elevation: 0,
      ),
    ),
    
    // 樱花飞舞
    ThemeData(
      primaryColor: const Color(0xFFFF8FB1),
      scaffoldBackgroundColor: const Color(0xFFFFF0F3),
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF8FB1),
        secondary: Color(0xFFFFE5EB),
        surface: Color(0xFFFFF0F3),
        background: Color(0xFFFFF0F3),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF855B69),
        onSurface: Color(0xFF855B69),
        onBackground: Color(0xFF855B69),
      ),
      cardColor: const Color(0xFFFFE5EB),
      dividerColor: const Color(0xFFFFD6E0),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF855B69)),
        bodyMedium: TextStyle(color: Color(0xFF855B69)),
        titleMedium: TextStyle(color: Color(0xFF855B69)),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF855B69),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF0F3),
        foregroundColor: Color(0xFF855B69),
        elevation: 0,
      ),
    ),
  ];

  static final List<String> themeNames = [
    '深邃夜空',
    '森林晨露',
    '紫罗兰黄昏',
    '晨曦云霭',
    '樱花飞舞',
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