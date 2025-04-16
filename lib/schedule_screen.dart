// lib/schedule_screen.dart
import 'package:flutter/material.dart';
// SystemUiOverlayStyle больше не нужен здесь, т.к. управляется из main.dart
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/schedule_day.dart';
import '../models/lesson.dart';
import '../mock_data.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // Хелпер isLessonNow остается
  bool isLessonNow(Lesson lesson, BuildContext context) {
    final timeRange = lesson.parseTimeRange();
    if (timeRange == null || timeRange.start == null || timeRange.end == null) {
      return false;
    }
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final startTime = timeRange.start!;
    final endTime = timeRange.end!;
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final String currentDayName = DateFormat(
      'EEEE',
      'ru',
    ).format(DateTime.now());
    final List<ScheduleDay> schedule = mockSchedule;
    final bool hasSchedule = schedule.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Scaffold без AnnotatedRegion
      appBar: AppBar(
        title: const Text('Расписание'),
      ), // AppBar использует стиль из main.dart
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child:
            hasSchedule
                ? ListView.separated(
                  // Используем ListView.separated для разделителей между ДНЯМИ
                  key: const ValueKey('schedule_list'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ), // Отступы для всего списка
                  itemCount: schedule.length,
                  // Строитель для дней
                  itemBuilder: (context, index) {
                    final daySchedule = schedule[index];
                    final bool isToday =
                        daySchedule.dayName.toLowerCase() ==
                        currentDayName.toLowerCase();
                    final bool hasLessonsToday = daySchedule.lessons.isNotEmpty;

                    // Блок для одного дня
                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок дня
                            _buildDayHeader(
                              context,
                              daySchedule.dayName,
                              isToday,
                            ),

                            const SizedBox(
                              height: 12,
                            ), // Отступ после заголовка дня
                            // Список уроков ИЛИ сообщение "Нет занятий"
                            if (hasLessonsToday)
                              // Используем Column для уроков, без обертки Card или ExpansionTile
                              Column(
                                // Генерируем виджеты уроков, передавая isToday
                                children: _buildLessonList(
                                  context,
                                  daySchedule.lessons,
                                  isToday,
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 8.0,
                                ), // Небольшой отступ
                                child: Text(
                                  'Нет занятий',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        )
                        .animate() // Анимация появления блока дня
                        .fadeIn(
                          duration: 350.ms,
                          delay: (index * 100).ms,
                        ) // Увеличил задержку
                        .moveY(
                          begin: 10,
                          end: 0,
                          duration: 350.ms,
                        ); // Небольшой сдвиг снизу
                  },
                  // Строитель разделителей между днями
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 32, // Увеличим пространство между днями
                        thickness: 1,
                        color:
                            colorScheme
                                .surfaceContainerHighest, // Цвет разделителя из темы
                      ),
                )
                : Center(
                  key: const ValueKey('no_schedule'),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Расписание пока недоступно.',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                ),
      ),
    );
  }

  // Виджет для заголовка дня
  Widget _buildDayHeader(BuildContext context, String dayName, bool isToday) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4.0,
        top: 4.0,
      ), // Отступы заголовка
      child: Row(
        children: [
          // Индикатор текущего дня (линия)
          if (isToday)
            Container(
              width: 4,
              height: 24, // Высота соответствует примерно тексту
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: 12),
            ),
          // Название дня
          Text(
            dayName,
            style: textTheme.titleLarge?.copyWith(
              // Крупный заголовок дня
              fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
              color: isToday ? colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  // Функция генерации списка виджетов уроков для одного дня
  List<Widget> _buildLessonList(
    BuildContext context,
    List<Lesson> lessons,
    bool isToday,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    List<Widget> lessonWidgets = [];
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final bool isCurrentLesson = isToday && isLessonNow(lesson, context);

      lessonWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10.0), // Отступ между уроками
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            // Легкий фон для всех уроков для визуального разделения
            color: colorScheme.surfaceContainer, // Чуть темнее/светлее фона
            borderRadius: BorderRadius.circular(12.0),
            // Яркая рамка для текущего урока
            border:
                isCurrentLesson
                    ? Border.all(color: colorScheme.primary, width: 2.0)
                    : Border.all(
                      color: Colors.transparent,
                      width: 0,
                    ), // Без рамки для остальных
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Выравниваем по центру вертикально
            children: [
              // Иконка урока
              Icon(
                lesson.icon ?? Icons.book_outlined,
                size: 24, // Чуть крупнее иконка урока
                color:
                    isCurrentLesson
                        ? colorScheme.primary
                        : colorScheme.secondary,
              ),
              const SizedBox(width: 14),
              // Текст урока
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold, // Всегда жирный предмет
                        // Цвет для текущего урока можно не менять, т.к. есть рамка
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${lesson.teacher}${lesson.room != null ? ' • ${lesson.room}' : ''}', // Используем точку как разделитель
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Время урока + индикатор "Сейчас"
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.timeRange, // Без переноса строки
                    style: textTheme.bodyMedium?.copyWith(
                      // Крупнее время
                      color:
                          isCurrentLesson
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isCurrentLesson ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  // Маленький чип "Сейчас"
                  if (isCurrentLesson)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Chip(
                        label: const Text('Сейчас'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        labelStyle: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                        backgroundColor: colorScheme.primary,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
      // Разделители между уроками больше не нужны, т.к. есть margin у Container
    }
    return lessonWidgets;
  }
}
