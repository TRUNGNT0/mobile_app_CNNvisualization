import 'package:flutter/material.dart';
import 'package:cnnvisualizer/features/home/presentation/home_screen.dart';
import 'package:cnnvisualizer/features/learning/presentation/learn_screen.dart';
import 'package:cnnvisualizer/features/profile/presentation/profile_screen.dart';
import 'package:cnnvisualizer/features/visualizer/presentation/visualizer_screen.dart';

void main() {
  runApp(const AIVisionLabApp());
}

class AIVisionLabApp extends StatelessWidget {
  const AIVisionLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Vision Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        primaryColor: const Color(0xFF528DFF),
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0F1115),
          surface: Color(0xFF1A1C22),
          primary: Color(0xFF528DFF),
          secondary: Color(0xFFD6BAFF),
          tertiary: Color(0xFFFFB77D),
          error: Color(0xFFFFB4AB),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2E2E8),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE2E2E8),
          ),
          titleMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE2E2E8),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.0,
            color: Color(0xFFC2C6D6),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.0,
            color: Color(0xFFC2C6D6),
          ),
          labelLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: Color(0xFF528DFF),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1C22),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    VisualizerScreen(),
    LearnScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1),
          ),
          color: Color(0xFF1A1C22),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.insights, 'Visualizer', 1),
              _buildNavItem(Icons.school, 'Learn', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF528DFF).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF528DFF) : const Color(0xFFC2C6D6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF528DFF) : const Color(0xFFC2C6D6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
