import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/teacher_schedule_provider.dart';
import '../../../models/schedule_entry.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/group_provider.dart';

class TeacherSchedulePage extends ConsumerStatefulWidget {
  final String teacherId;

  const TeacherSchedulePage({super.key, required this.teacherId});

  @override
  ConsumerState<TeacherSchedulePage> createState() =>
      _TeacherSchedulePageState();
}

class _TeacherSchedulePageState extends ConsumerState<TeacherSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<int> _daysOfWeek = List.generate(6, (index) => index + 1);
  final List<String> _dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _daysOfWeek.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(teacherScheduleProvider(widget.teacherId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: List.generate(
            _daysOfWeek.length,
            (index) => Tab(text: _dayNames[index]),
          ),
        ),
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (lessons) {
          if (lessons.isEmpty) {
            return Center(
              child: Text(
                'Нет данных о расписании',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children:
                _daysOfWeek.map((day) {
                  // Фильтруем уроки по выбранному дню
                  final dayLessons =
                      lessons
                          .where((lesson) => lesson.dayOfWeek == day)
                          .toList();

                  // Сортируем уроки по времени начала
                  dayLessons.sort((a, b) => a.startTime.compareTo(b.startTime));

                  if (dayLessons.isEmpty) {
                    return Center(
                      child: Text(
                        'Нет уроков на ${_getDayName(day).toLowerCase()}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = dayLessons[index];
                      return _LessonListTile(lesson: lesson);
                    },
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[dayOfWeek - 1];
  }
}

class _LessonListTile extends ConsumerWidget {
  final ScheduleEntry lesson;

  const _LessonListTile({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Получаем название предмета
    final subjectAsync = ref.watch(subjectProvider(lesson.subjectId));
    // ИСПРАВЛЕНО: Используем groupNameProvider вместо groupProvider
    final groupNameAsync = ref.watch(groupNameProvider(lesson.groupId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Показать детали урока
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getLessonTypeIcon(lesson.type),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lesson.startTime} - ${lesson.endTime}',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLessonTypeName(lesson.type),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: subjectAsync.when(
                      data:
                          (subject) => Text(
                            'Предмет: ${subject?.name ?? lesson.subjectId}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      loading: () => const Text('Загрузка...'),
                      error:
                          (_, __) => Text(
                            'Предмет: ${lesson.subjectId}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: groupNameAsync.when(
                      data: (groupName) {
                        print(
                          'DEBUG: _LessonListTile: Group name received: $groupName',
                        );
                        return Text(
                          'Группа: $groupName',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                      loading: () => const Text('Загрузка группы...'),
                      error: (error, stack) {
                        print(
                          'DEBUG: _LessonListTile: Error loading group name: $error',
                        );
                        return Text(
                          'Группа: ${lesson.groupId}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (lesson.room.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.room_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Аудитория: ${lesson.room}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type) {
      case 'lecture':
        return Icons.school;
      case 'seminar':
        return Icons.groups;
      case 'lab':
        return Icons.computer;
      default:
        return Icons.class_;
    }
  }

  String _getLessonTypeName(String type) {
    switch (type) {
      case 'lecture':
        return 'Лекция';
      case 'seminar':
        return 'Семинар';
      case 'lab':
        return 'Лабораторная работа';
      default:
        return 'Урок';
    }
  }
}
