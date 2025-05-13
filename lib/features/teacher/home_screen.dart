// lib/features/teacher/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/teacher/providers/journal_providers.dart';
import 'package:flutter_application_1/features/teacher/widgets/schedule_entry_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_service.dart';
// import '../../providers/teacher_provider.dart'; // Провайдер для данных учителя, если он есть

// --- Импорты страниц (ЗАГЛУШКИ - замените на реальные импорты позже) ---
import 'pages/schedule_page.dart';
import 'pages/journal_page.dart'; // Новая страница для оценок и посещаемости
import 'pages/assignments_page.dart';
import 'pages/profile_page.dart';

import '../../models/schedule_entry.dart';
import 'widgets/schedule_search.dart';
import 'providers/teacher_schedule_provider.dart';
import 'widgets/schedule_export_service.dart';
import 'providers/schedule_service.dart';

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

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late TabController _scheduleTabController;
  final List<String> _scheduleDayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
  bool _isScheduleSearching = false;
  String? _selectedGroupId;
  String? _selectedSubject;
  List<ScheduleEntry> _filteredLessons = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _scheduleTabController = TabController(
      length: _scheduleDayNames.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scheduleTabController.dispose();
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
      if (index != 0 && _isScheduleSearching) {
        _isScheduleSearching = false;
        _filteredLessons = [];
      }
    });
  }

  List<Widget> _buildAppBarActions() {
    if (_selectedIndex == 0) {
      return [
        IconButton(
          icon: Icon(_isScheduleSearching ? Icons.close : Icons.search),
          tooltip:
              _isScheduleSearching ? 'Закрыть поиск' : 'Поиск по расписанию',
          onPressed: () {
            setState(() {
              _isScheduleSearching = !_isScheduleSearching;
              if (!_isScheduleSearching) _filteredLessons = [];
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Экспорт расписания',
          onSelected: (value) async {
            if (value == 'pdf') {
              await ScheduleExportService.exportToPdf(
                context,
                ref,
                _selectedGroupId,
                _selectedSubject,
              );
            } else if (value == 'excel') {
              await ScheduleExportService.exportToExcel(
                context,
                ref,
                _selectedGroupId,
                _selectedSubject,
              );
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined),
                      SizedBox(width: 8),
                      Text('Экспорт в PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined),
                      SizedBox(width: 8),
                      Text('Экспорт в Excel'),
                    ],
                  ),
                ),
              ],
        ),
      ];
    } else if (_selectedIndex == 3) {
      return [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Настройки',
          onPressed: () => GoRouter.of(context).push('/settings'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Выйти',
          onPressed: _handleSignOut,
        ),
      ];
    }
    return [];
  }

  PreferredSizeWidget? _buildAppBarBottom() {
    if (_selectedIndex == 0) {
      return PreferredSize(
        preferredSize: Size.fromHeight(_isScheduleSearching ? 104.0 : 48.0),
        child: Column(
          children: [
            TabBar(
              controller: _scheduleTabController,
              isScrollable: true,
              tabs: _scheduleDayNames.map((name) => Tab(text: name)).toList(),
            ),
            if (_isScheduleSearching)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final scheduleAsync = ref.watch(teacherScheduleProvider);
                    return scheduleAsync.when(
                      data:
                          (lessons) => ScheduleSearch(
                            allLessons: lessons,
                            onSearchResults: (results) {
                              setState(() => _filteredLessons = results);
                            },
                          ),
                      loading:
                          () => const SizedBox(
                            height: 52,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      error:
                          (_, __) => const SizedBox(
                            height: 52,
                            child: Center(
                              child: Text('Ошибка загрузки для поиска'),
                            ),
                          ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }
    return null;
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

  void _handleReorder(List<ScheduleEntry> newList) async {
    for (var i = 0; i < newList.length; i++) {
      final lesson = newList[i];
      if (lesson.id != null && lesson.groupId != null) {
        await ref
            .read(scheduleServiceProvider)
            .updateLessonOrder(lesson.id!, lesson.groupId!, i + 1);
      }
    }
    ref.invalidate(teacherScheduleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Расписание', 'Журнал', 'Задания', 'Профиль'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: _buildAppBarActions(),
        bottom: _buildAppBarBottom(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          SchedulePage(
            tabController: _scheduleTabController,
            isSearching: _isScheduleSearching,
            searchResults: _filteredLessons,
            selectedGroupId: _selectedGroupId,
            selectedSubject: _selectedSubject,
            onReorderLessons: _handleReorder,
          ),
          const JournalPage(),
          const AssignmentsPage(),
          const TeacherProfilePage(),
        ],
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
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
        child:
            _selectedIndex == 0
                ? FloatingActionButton(
                  key: const ValueKey('fab-schedule'),
                  onPressed: () async {
                    final asyncGroupsInfo = ref.read(
                      teacherSubjectsAndGroupsProvider,
                    );
                    asyncGroupsInfo.whenData((groups) async {
                      if (groups.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Сначала должны быть созданы группы.',
                            ),
                          ),
                        );
                        return;
                      }
                      if (!context.mounted) return;
                      final currentDayOfWeek = _scheduleTabController.index + 1;
                      final result = await ScheduleEntryDialog.show(
                        context,
                        ref,
                        groups,
                        dayOfWeekForNew: currentDayOfWeek,
                      );
                      if (result != null) {
                        ref.invalidate(teacherScheduleProvider);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Занятие добавлено'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  },
                  tooltip: 'Добавить занятие',
                  child: const Icon(Icons.add),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
