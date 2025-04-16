import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для SystemUiOverlayStyle
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/schedule_day.dart';
import '../models/lesson.dart';
import '../mock_data.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // Хелпер isLessonNow остается без изменений
  bool isLessonNow(Lesson lesson, BuildContext context) {
    // ... (код хелпера как в предыдущем ответе) ...
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Определяем стиль для системных панелей
    final systemUiStyle = SystemUiOverlayStyle(
      // Строка состояния (сверху)
      statusBarColor: Colors.transparent, // Прозрачный фон
      statusBarIconBrightness:
          isDark
              ? Brightness.light
              : Brightness.dark, // Иконки темные/светлые в зависимости от темы
      statusBarBrightness:
          isDark ? Brightness.dark : Brightness.light, // Для iOS
      // Панель навигации (снизу)
      systemNavigationBarColor:
          colorScheme.surface, // Цвет фона панели как у Scaffold
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Иконки на панели
    );

    // Оборачиваем Scaffold для применения стиля системных панелей
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        // Можно применить стиль и к AppBar, чтобы он влиял на статус бар над ним
        appBar: AppBar(
          title: const Text('Расписание'),
          backgroundColor: Colors.transparent, // Делаем AppBar прозрачным
          elevation: 0, // Убираем тень AppBar
          foregroundColor: colorScheme.onSurface, // Цвет текста и иконок AppBar
          systemOverlayStyle:
              systemUiStyle, // Применяем стиль к статус бару над AppBar
        ),
        // Используем цвет фона основной темы
        backgroundColor: colorScheme.surface,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child:
              hasSchedule
                  ? ListView.builder(
                    key: const ValueKey('schedule_list'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ), // Немного увеличил гор. отступ
                    itemCount: schedule.length,
                    itemBuilder: (context, index) {
                      final daySchedule = schedule[index];
                      final bool isToday =
                          daySchedule.dayName.toLowerCase() ==
                          currentDayName.toLowerCase();
                      final bool hasLessonsToday =
                          daySchedule.lessons.isNotEmpty;

                      return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation:
                                isToday
                                    ? 1.5
                                    : 0.5, // Очень маленькая тень или почти нет
                            // Убираем фоновый цвет для текущего дня
                            color:
                                colorScheme
                                    .surfaceContainerHighest, // Цвет фона карточки из темы
                            // Добавляем рамку для текущего дня как акцент
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12.0,
                              ), // Стандартное скругление из темы
                              side:
                                  isToday
                                      ? BorderSide(
                                        color: colorScheme.primary,
                                        width: 1.5,
                                      ) // Рамка для текущего дня
                                      : BorderSide(
                                        color: colorScheme.outlineVariant
                                            .withOpacity(0.5),
                                        width: 0.5,
                                      ), // Тонкая граница для остальных
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ExpansionTile(
                              key: PageStorageKey(daySchedule.dayName),
                              initiallyExpanded: isToday && hasLessonsToday,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ), // Немного увеличил верт. отступ
                              childrenPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.calendar_today_outlined,
                                color:
                                    isToday
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                size: 20, // Уменьшим иконку дня
                              ),
                              title: Text(
                                daySchedule.dayName,
                                style: textTheme.titleMedium?.copyWith(
                                  // Используем titleMedium
                                  fontWeight:
                                      isToday
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color: isToday ? colorScheme.primary : null,
                                ),
                              ),
                              subtitle: Text(
                                hasLessonsToday
                                    ? '${daySchedule.lessons.length} пар(ы)'
                                    : 'Нет пар',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ), // Цвет из темы
                              ),
                              children:
                                  hasLessonsToday
                                      ? ListTile.divideTiles(
                                        context: context,
                                        // Убираем цвет разделителя, делаем его стандартным
                                        // color: isToday ? colorScheme.primaryContainer.withAlpha(150) : null,
                                        tiles: daySchedule.lessons.map((
                                          lesson,
                                        ) {
                                          final bool isCurrentLesson =
                                              isToday &&
                                              isLessonNow(lesson, context);

                                          // Используем ListTile напрямую, без Container
                                          return ListTile(
                                            // Выделяем текущий урок через selected и selectedTileColor
                                            selected: isCurrentLesson,
                                            selectedTileColor: colorScheme
                                                .primary
                                                .withAlpha(
                                                  30,
                                                ), // Очень легкий акцент
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 6.0,
                                                ), // Настраиваем отступы ListTile
                                            leading: Icon(
                                              lesson.icon ??
                                                  Icons.book_outlined,
                                              size: 22,
                                              color:
                                                  isCurrentLesson
                                                      ? colorScheme.primary
                                                      : colorScheme
                                                          .secondary, // Другой цвет для иконок уроков
                                            ),
                                            title: Text(
                                              lesson.subject,
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(
                                                    // Используем bodyLarge
                                                    fontWeight:
                                                        isCurrentLesson
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                  ),
                                            ),
                                            subtitle: Padding(
                                              // Добавим отступ сверху для подзаголовка
                                              padding: const EdgeInsets.only(
                                                top: 2.0,
                                              ),
                                              child: Text(
                                                '${lesson.teacher}${lesson.room != null ? ' (${lesson.room})' : ''}',
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                            trailing: Text(
                                              lesson.timeRange.replaceAll(
                                                ' - ',
                                                '\n',
                                              ),
                                              textAlign: TextAlign.right,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        isCurrentLesson
                                                            ? colorScheme
                                                                .primary
                                                            : colorScheme
                                                                .outline,
                                                    fontWeight:
                                                        isCurrentLesson
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    height: 1.3,
                                                  ),
                                            ),
                                          );
                                        }),
                                      ).toList()
                                      : [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                          ),
                                          child: Text(
                                            'В этот день нет занятий',
                                            textAlign: TextAlign.center,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: (index * 80).ms)
                          .slideX(begin: index % 2 == 0 ? -0.1 : 0.1);
                    },
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
      ),
    );
  }
}
