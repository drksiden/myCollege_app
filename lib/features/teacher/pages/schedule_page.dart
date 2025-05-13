// lib/features/teacher/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Провайдеры и модели
import '../providers/teacher_schedule_provider.dart';
import '../../../models/schedule_entry.dart';

// Общий виджет карточки урока (предполагаем, что он будет вынесен или скопирован)
// TODO: Вынести _LessonCard в общий каталог widgets или скопировать/адаптировать
// import '../../../widgets/lesson_card.dart'; // Пример, если вынесли
// Пока используем копию из student/schedule_page.dart (нужно будет создать)

// --- ЗАГЛУШКА: Скопируйте или импортируйте ваш виджет _LessonCard ---
const double _borderRadiusValue =
    12.0; // Предполагаем, что эта константа доступна

class _LessonCard extends StatelessWidget {
  final ScheduleEntry lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Для учителя индикатор "сейчас идет" может быть менее актуален, но оставим для консистентности
    final bool isCurrent = lesson.isCurrentLesson();

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape:
          isCurrent
              ? RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.primary, width: 1.5),
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
                if (isCurrent) // Индикатор "Сейчас"
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
            // Разделитель
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 1.5,
                height: 50, // Примерная высота
                color: colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            // Информация о паре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject, // Предмет
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // --- Добавляем Группу ---
                  if (lesson.groupId !=
                      null) // Предполагаем, что groupId будет в ScheduleEntry (нужно добавить!)
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 14,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // TODO: Нужно будет получать имя группы по lesson.groupId
                            "Группа: ${lesson.groupId}", // Пока показываем ID
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ------------------------
                  if (lesson.lessonType != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        lesson.lessonType!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Учитель тут не нужен, так как это расписание самого учителя
                  // Row(...) с lesson.teacherName убираем
                  if (lesson.classroom != null)
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
                            lesson.classroom!,
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
}
// --------------------------------------------------------------

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Пн-Сб
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
    // Следим за сгруппированным расписанием УЧИТЕЛЯ
    final groupedSchedule = ref.watch(groupedTeacherScheduleProvider);
    // Следим за асинхронным состоянием основного провайдера для загрузки/ошибки
    final asyncSchedule = ref.watch(teacherScheduleProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // AppBar будет в TeacherHomeScreen, здесь он не нужен
      body: asyncSchedule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('Error loading teacher schedule: $error \n$stack');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ошибка загрузки расписания.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data:
            (_) => Column(
              // Оборачиваем в Column для TabBar и TabBarView
              children: [
                // --- Вкладки Дней Недели ---
                TabBar(
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
                // --- Содержимое Вкладок ---
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(_daysOfWeek.length, (tabIndex) {
                      final dayOfWeek = _daysOfWeek[tabIndex];
                      final lessonsForDay = groupedSchedule[dayOfWeek] ?? [];

                      return RefreshIndicator(
                        color: colorScheme.primary,
                        onRefresh: () async {
                          // Обновляем данные провайдера
                          ref.invalidate(teacherScheduleProvider);
                          // Можно подождать первое значение после обновления
                          await ref.read(teacherScheduleProvider.future);
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
                                    // Используем _LessonCard для отображения
                                    return _LessonCard(lesson: lesson)
                                        .animate()
                                        .fadeIn(
                                          delay: (lessonIndex * 70).ms,
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
                  ),
                ),
                // --- Кнопка добавления/редактирования (пока закомментирована) ---
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: ElevatedButton.icon(
                //     icon: Icon(Icons.add),
                //     label: Text("Добавить занятие"),
                //     onPressed: () {
                //       // TODO: Реализовать навигацию на экран добавления/редактирования
                //     },
                //   ),
                // )
              ],
            ),
      ),
      // --- Плавающая кнопка добавления ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Реализовать навигацию или показ диалога для добавления/редактирования занятия
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('TODO: Добавить/редактировать занятие'),
            ),
          );
        },
        child: const Icon(
          Icons.edit_calendar_outlined,
        ), // Иконка редактирования календаря
        tooltip: 'Добавить/Редактировать занятие',
      ),
    );
  }
}
