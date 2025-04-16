import 'package:flutter/material.dart';
import 'package:flutter_application_1/activity_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../mock_data.dart'; // Импортируем mock данные и утилиты

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем тему
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Сортируем активности по дате (как в ScheduleScreen: будущие -> прошедшие)
    final List<Map<String, dynamic>> sortedActivities = List.from(
      mockActivities,
    );
    final now = DateTime.now();
    sortedActivities.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      final aIsFuture = dateA.isAfter(now) || DateUtils.isSameDay(dateA, now);
      final bIsFuture = dateB.isAfter(now) || DateUtils.isSameDay(dateB, now);
      if (aIsFuture && !bIsFuture) return -1;
      if (!aIsFuture && bIsFuture) return 1;
      if (aIsFuture) return dateA.compareTo(dateB);
      return dateB.compareTo(dateA);
    });

    final bool hasActivities = sortedActivities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Активности'),
        // AppBar использует стиль из main.dart (прозрачный, без тени)
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child:
            hasActivities
                ? ListView.builder(
                  // Можно заменить на ListView.separated, если нужны разделители
                  key: const ValueKey('activities_list'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  itemCount: sortedActivities.length,
                  itemBuilder: (context, index) {
                    final activity = sortedActivities[index];
                    final date = DateFormat(
                      'EEEE, d MMMM yyyy г.',
                      'ru',
                    ).format(DateTime.parse(activity['date']));
                    // Получаем цвет и иконку через утилиты (убедитесь, что getActivityColor использует context)
                    final color = getActivityColor(context, activity['type']);
                    final icon = getActivityIcon(activity['type']);

                    // Используем Container вместо Card для плоского вида
                    return Container(
                          margin: const EdgeInsets.only(
                            bottom: 12.0,
                          ), // Отступ между активностями
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            // Цвет фона чуть отличается от основного фона Scaffold
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12.0),
                            // Убрали рамку, можно добавить если нужно:
                            // border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5))
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Иконка в кружке
                              CircleAvatar(
                                radius: 20, // Размер кружка
                                backgroundColor: color.withAlpha(
                                  50,
                                ), // Полупрозрачный фон иконки
                                foregroundColor: color, // Цвет самой иконки
                                child: Icon(icon, size: 20), // Размер иконки
                              ),
                              const SizedBox(width: 16),
                              // Текстовый контент
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок
                                    Text(
                                      activity['title'],
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ), // Стиль темы
                                    ),
                                    const SizedBox(height: 6),
                                    // Описание
                                    Text(
                                      activity['description'],
                                      // ЯВНО задаем цвет текста через тему!
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Дата
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: colorScheme.outline,
                                        ), // Цвет иконки даты из темы
                                        const SizedBox(width: 6),
                                        Text(
                                          date,
                                          // ЯВНО задаем цвет текста через тему!
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate() // Анимация
                        .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                        .moveY(begin: 10, end: 0); // Сдвиг снизу
                  },
                )
                : Center(
                  // Отображение, если список активностей пуст
                  key: const ValueKey(
                    'no_activities',
                  ), // Ключ для AnimatedSwitcher
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Пока нет доступных активностей.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      delay: 200.ms,
                    ), // Появление с небольшой задержкой
                  ),
                ),
      ),
    );
  }
}

// Напоминание: Убедитесь, что функция getActivityColor в mock_data.dart
// принимает BuildContext и использует colorScheme для цветов, например:
/*
Color getActivityColor(BuildContext context, String type) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (type) {
    case 'academic': return colorScheme.primary;
    case 'event': return Colors.orange.shade700; // Или colorScheme.tertiary
    case 'social': return Colors.green.shade600; // Или colorScheme.secondary
    default: return colorScheme.onSurfaceVariant;
  }
}
*/
