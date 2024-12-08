import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static ThemeService? _instance;
  
  static final List<ThemeData> themes = [
    // 晴空蓝
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
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE0E5EB),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF4A5B73),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF4A5B73),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF4A5B73),
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4A5B73)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // 森林晨露 -> 清新绿
    ThemeData(
      primaryColor: const Color(0xFF7BCEA0),
      scaffoldBackgroundColor: const Color(0xFFF8FCFA),
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7BCEA0),
        secondary: Color(0xFFE8F6F0),
        surface: Color(0xFFF8FCFA),
        background: Color(0xFFF8FCFA),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF2D5242),
        onSurface: Color(0xFF2D5242),
        onBackground: Color(0xFF2D5242),
      ),
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE0EBE5),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF2D5242),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF2D5242),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF2D5242),
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2D5242)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // 紫罗兰黄昏 -> 梦幻紫
    ThemeData(
      primaryColor: const Color(0xFFB784E0),
      scaffoldBackgroundColor: const Color(0xFFFCF8FF),
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFB784E0),
        secondary: Color(0xFFF4E8FF),
        surface: Color(0xFFFCF8FF),
        background: Color(0xFFFCF8FF),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF583D71),
        onSurface: Color(0xFF583D71),
        onBackground: Color(0xFF583D71),
      ),
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE8E0EB),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF583D71),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF583D71),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF583D71),
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF583D71)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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