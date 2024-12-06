import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_player_bar.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 监听主题变化
    ThemeService.instance.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeService.instance.currentTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),  // 动画持续时间
        switchInCurve: Curves.easeInOut,             // 进入动画曲线
        switchOutCurve: Curves.easeInOut,            // 退出动画曲线
        transitionBuilder: (child, animation) {
          return FadeTransition(                     // 使用淡入淡出效果
            opacity: animation,
            child: SlideTransition(                  // 同时添加滑动效果
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),         // 从右侧轻微滑入
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedIndex != 0) const BottomPlayerBar(),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            animationDuration: const Duration(milliseconds: 300),  // 导航栏动画时间
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.headphones_outlined),
                selectedIcon: Icon(Icons.headphones),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.album_outlined),
                selectedIcon: Icon(Icons.album),
                label: '资料库',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: '设置',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
