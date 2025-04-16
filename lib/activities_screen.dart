import 'package:flutter/material.dart';
import 'package:flutter_application_1/activity_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../mock_data.dart'; // Импортируем mock данные и утилиты

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем и сортируем активности: сначала будущие (от ближайшей), потом прошедшие (от недавней)
    final List<Map<String, dynamic>> sortedActivities = List.from(
      mockActivities,
    );
    final now = DateTime.now(); // Текущая дата для сравнения

    sortedActivities.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);

      // Сравниваем относительно текущей даты
      final aIsFuture = dateA.isAfter(now) || DateUtils.isSameDay(dateA, now);
      final bIsFuture = dateB.isAfter(now) || DateUtils.isSameDay(dateB, now);

      if (aIsFuture && !bIsFuture) return -1; // Будущие идут первыми
      if (!aIsFuture && bIsFuture) return 1; // Прошедшие идут последними

      if (aIsFuture) {
        // Обе будущие - сортируем от ближайшей к дальней
        return dateA.compareTo(dateB);
      } else {
        // Обе прошедшие - сортируем от недавней к старой
        return dateB.compareTo(dateA);
      }
    });

    final bool hasActivities = sortedActivities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Активности')),
      body: AnimatedSwitcher(
        // Анимация для переключения между списком и пустым состоянием
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child:
            hasActivities
                ? ListView.builder(
                  key: const ValueKey(
                    'activities_list',
                  ), // Ключ для AnimatedSwitcher
                  padding: const EdgeInsets.all(16), // Отступы для всего списка
                  itemCount: sortedActivities.length,
                  itemBuilder: (context, index) {
                    final activity = sortedActivities[index];
                    // Форматируем дату, можно добавить день недели
                    final date = DateFormat(
                      'EEEE, d MMMM yyyy г.',
                      'ru',
                    ).format(DateTime.parse(activity['date']));
                    // Получаем цвет и иконку через утилиты
                    final color = getActivityColor(context, activity['type']);
                    final icon = getActivityIcon(activity['type']);

                    // Карточка активности
                    return Card(
                          // Используем общую тему CardTheme, но добавляем нижний отступ
                          margin: const EdgeInsets.only(bottom: 16),
                          // Можно убрать shape и elevation, если они такие же как в теме
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          // elevation: 3,
                          clipBehavior:
                              Clip.antiAlias, // Для красивого эффекта InkWell
                          child: InkWell(
                            // Добавляем реакцию на нажатие
                            onTap: () {
                              // TODO: Добавить действие при нажатии (например, показать детали)
                              print('Tapped on: ${activity['title']}');
                            },
                            child: Padding(
                              // Отступы внутри карточки
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                // Используем Row для лучшего контроля над расположением
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Иконка слева
                                  CircleAvatar(
                                    backgroundColor: color.withOpacity(
                                      0.15,
                                    ), // Чуть насыщеннее фон
                                    foregroundColor: color,
                                    child: Icon(icon),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ), // Отступ между иконкой и текстом
                                  // Текстовый контент справа
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Заголовок
                                        Text(
                                          activity['title'],
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            fontSize: 18,
                                          ), // Используем стиль темы
                                        ),
                                        const SizedBox(height: 6),
                                        // Описание
                                        Text(
                                          activity['description'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.black54),
                                        ),
                                        const SizedBox(height: 10),
                                        // Дата
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.date_range_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              date,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 12,
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
                          ),
                        )
                        // Анимация появления карточки
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (index * 70).ms,
                        ) // Немного медленнее
                        .slideY(
                          begin: 0.3,
                          end: 0.0,
                          curve: Curves.easeOutCirc,
                        ); // Другая кривая для разнообразия
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
