// lib/features/student/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'page/teacher_schedule_page.dart';
import 'page/teacher_grades_page.dart';
import 'page/teacher_tasks_page.dart';
import 'page/teacher_profile_page.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    TeacherSchedulePage(),
    TeacherGradesPage(),
    TeacherTasksPage(),
    TeacherProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель учителя'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Оценки'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}