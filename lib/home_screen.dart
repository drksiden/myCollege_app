import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'grades_screen.dart';
import 'performance_screen.dart';
import 'activities_screen.dart';
import 'profile_screen.dart';
import 'qr_scan_screen.dart'; // Импортируем экран сканирования

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ScheduleScreen(),
    GradesScreen(),
    PerformanceScreen(),
    ActivitiesScreen(),
    QrScanScreen(), // Добавили новый экран
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Пары'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Оценки'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR-отметка'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Успеваемость'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Активности'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
