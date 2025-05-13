// lib/features/teacher/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_service.dart';
// import '../../providers/teacher_provider.dart'; // Провайдер для данных учителя, если он есть

// --- Импорты страниц (ЗАГЛУШКИ - замените на реальные импорты позже) ---
import 'pages/schedule_page.dart';
import 'pages/journal_page.dart'; // Новая страница для оценок и посещаемости
// import 'pages/assignments_page.dart';
// import 'pages/profile_page.dart';

// --- Виджет для сохранения состояния вкладки (можно вынести в отдельный файл) ---
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Важно вызвать super.build
    return widget.child;
  }

  // Возвращаем true, чтобы сохранить состояние
  @override
  bool get wantKeepAlive => true;
}
// ---------------------------------------------

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // --- ЗАГЛУШКИ СТРАНИЦ ---
  // Замените их на реальные виджеты страниц, когда они будут готовы
  final List<Widget> _pages = const [
    KeepAliveWrapper(child: SchedulePage()), // Index 0
    KeepAliveWrapper(child: JournalPage()), // Index 1
    KeepAliveWrapper(
      child: Center(child: Text('Страница Заданий/Материалов')),
    ), // Index 2
    KeepAliveWrapper(
      child: Center(child: Text('Страница Профиля (Учитель)')),
    ), // Index 3
    // KeepAliveWrapper(child: AssignmentsPage()),
    // KeepAliveWrapper(child: TeacherProfilePage()),
  ];

  // Названия для AppBar
  final List<String> _titles = const [
    'Расписание',
    'Журнал', // Общее название для оценок/посещаемости
    'Задания',
    'Профиль',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleSignOut() async {
    // Можно добавить диалог подтверждения
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Выйти',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).signOut();
        // GoRouter автоматически перенаправит на /login
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при выходе: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Добавить .when() для teacherProfileProvider
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: _handleSignOut,
            ),
          IconButton(
            // Кнопка настроек всегда видна
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages, // <-- Используем обновленный список
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Задания',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
