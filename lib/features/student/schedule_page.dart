import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/student/providers/schedule_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/subject_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/schedule_entry.dart';
import '../../models/subject.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
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
      body: ref
          .watch(scheduleProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ошибка загрузки расписания.\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            data: (schedule) {
              // Получаем все предметы
              final allSubjectsAsync = ref.watch(subjectsProvider);

              return allSubjectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Ошибка загрузки предметов.\n$error',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                data: (allSubjects) {
                  // Группируем расписание по дням недели
                  final grouped = <int, List<ScheduleEntry>>{};
                  for (final entry in schedule) {
                    grouped.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: List.generate(_daysOfWeek.length, (tabIndex) {
                      final dayOfWeek = _daysOfWeek[tabIndex];
                      final lessonsForDay = grouped[dayOfWeek] ?? [];
                      return RefreshIndicator(
                        color: colorScheme.primary,
                        onRefresh: () async {
                          ref.invalidate(scheduleProvider);
                          ref.invalidate(subjectsProvider);
                          return;
                        },
                        child:
                            lessonsForDay.isEmpty
                                ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: Center(
                                          child:
                                              Text(
                                                'Нет занятий в этот день',
                                                style: textTheme.titleMedium
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                              ).animate().fadeIn(),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16.0),
                                  itemCount: lessonsForDay.length,
                                  itemBuilder: (context, lessonIndex) {
                                    final lesson = lessonsForDay[lessonIndex];
                                    return _LessonCard(
                                          lesson: lesson,
                                          subject:
                                              allSubjects[lesson.subjectId],
                                        )
                                        .animate()
                                        .fadeIn(
                                          delay: (lessonIndex * 80).ms,
                                          duration: 300.ms,
                                        )
                                        .moveX(
                                          begin: -10,
                                          end: 0,
                                          duration: 300.ms,
                                        );
                                  },
                                ),
                      );
                    }),
                  );
                },
              );
            },
          ),
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final ScheduleEntry lesson;
  final Subject? subject;
  const _LessonCard({required this.lesson, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCurrent = _isCurrentLesson(lesson);

    print(
      'DEBUG: _LessonCard building for lesson with teacherId: ${lesson.teacherId}',
    );
    final teacherNameAsync = ref.watch(teacherNameProvider(lesson.teacherId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape:
          isCurrent
              ? RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.primary, width: 2.0),
                borderRadius: BorderRadius.circular(_borderRadiusValue),
              )
              : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Время
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.startTime,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isCurrent ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.endTime,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Chip(
                          label: const Text('ИДЕТ'),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(
                          duration: 1200.ms,
                          color: colorScheme.primary.withAlpha(80),
                        ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 1.5,
                height: 50,
                color: colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject?.name ?? 'Неизвестный предмет',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      _getLessonType(lesson.type),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: teacherNameAsync.when(
                          data:
                              (name) => Text(
                                name,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          loading:
                              () => Text(
                                'Загрузка... (ID: ${lesson.teacherId})',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          error:
                              (e, s) => Text(
                                'Ошибка: $e',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lesson.room,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCurrentLesson(ScheduleEntry lesson) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return lesson.dayOfWeek == now.weekday &&
        lesson.startTime.compareTo(currentTime) <= 0 &&
        lesson.endTime.compareTo(currentTime) >= 0;
  }

  String _getLessonType(String type) {
    switch (type) {
      case 'lecture':
        return 'Лекция';
      case 'practice':
        return 'Практика';
      case 'lab':
        return 'Лабораторная';
      default:
        return type;
    }
  }
}

const double _borderRadiusValue = 12.0;
