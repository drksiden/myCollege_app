import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth_service.dart';

// Импорт нужных страниц
import 'pages/schedule_page.dart';
import 'pages/grades_page.dart';
import 'pages/assignments_page.dart';
import 'pages/profile_page.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    SchedulePage(),
    GradesPage(),
    AssignmentsPage(),
    TeacherProfilePage(),
  ];

  final List<String> _titles = [
    'Расписание',
    'Оценки',
    'Задания',
    'Профиль',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _selectedIndex == 3
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                ),
              ]
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
          
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
          
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
          
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            
          ),
        ],
      ),
    );
  }
}
