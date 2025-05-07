// lib/features/student/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/schedule_entry.dart'; // Наша модель
import 'providers/schedule_provider.dart'; // Наш провайдер

class SchedulePage extends ConsumerStatefulWidget {
  // Используем StatefulWidget для TabController
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Определяем дни недели для вкладок (например, Пн-Сб)
  final List<int> _daysOfWeek = List.generate(
    6,
    (index) => index + 1,
  ); // 1=Пн, ..., 6=Сб
  final List<String> _dayNames = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
  ]; // Названия для вкладок

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _daysOfWeek.length, vsync: this);
    // Добавим слушатель, чтобы обновлять что-то при смене таба, если нужно
    // _tabController.addListener(_handleTabSelection);
  }

  // void _handleTabSelection() {
  //   if (_tabController.indexIsChanging) {
  //     // Можно вызывать здесь какую-то логику при смене таба
  //     // print("Selected Day Index: ${_tabController.index}");
  //   }
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Следим за сгруппированным расписанием
    final groupedSchedule = ref.watch(groupedScheduleProvider);
    // Следим за асинхронным состоянием основного провайдера для отображения загрузки/ошибки
    final asyncSchedule = ref.watch(scheduleProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false, // Или true, если дней много
          indicatorColor:
              colorScheme.primary, // Цвет подчеркивания активной вкладки
          labelColor: colorScheme.primary, // Цвет текста активной вкладки
          unselectedLabelColor:
              colorScheme.onSurfaceVariant, // Цвет текста неактивных вкладок
          tabs: List.generate(
            _daysOfWeek.length,
            (index) => Tab(text: _dayNames[index]), // Генерируем вкладки Пн-Сб
          ),
        ),
      ),
      body: asyncSchedule.when(
        // --- Состояние ЗАГРУЗКИ ---
        loading: () => const Center(child: CircularProgressIndicator()),
        // --- Состояние ОШИБКИ ---
        error: (error, stack) {
          debugPrint('Error loading schedule: $error \n$stack');
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
        // --- Состояние ДАННЫХ ---
        data:
            (_) => TabBarView(
              // Используем _ чтобы показать, что сами данные берем из groupedSchedule
              controller: _tabController,
              children: List.generate(_daysOfWeek.length, (tabIndex) {
                // Получаем номер дня недели для текущей вкладки (1-6)
                final dayOfWeek = _daysOfWeek[tabIndex];
                // Получаем список пар для этого дня из сгруппированных данных
                final lessonsForDay = groupedSchedule[dayOfWeek] ?? [];

                return RefreshIndicator(
                  // Цвет индикатора
                  color: Theme.of(context).colorScheme.primary,
                  // Функция, которая будет вызвана при свайпе вниз
                  onRefresh: () async {
                    // Для StreamProvider, который слушает snapshots(),
                    // ручной рефреш часто не дает видимого эффекта,
                    // т.к. данные обновляются сами.
                    // Но для UX и на случай проблем с потоком можно сделать так:
                    ref.invalidate(scheduleProvider); // Пересоздаст провайдер
                    // Или можно подождать следующего значения из стрима:
                    // await ref.read(scheduleProvider.future);
                    // Дадим небольшую паузу для имитации загрузки
                    // await Future.delayed(const Duration(milliseconds: 500));
                    return; // Завершаем Future
                  },
                  // Содержимое вкладки (ListView или сообщение)
                  child:
                      lessonsForDay.isEmpty
                          ? LayoutBuilder(
                            // Используем LayoutBuilder чтобы Center растянулся
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                // Для возможности скролла RefreshIndicator
                                physics: const AlwaysScrollableScrollPhysics(),
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
                            // Важно: Добавляем physics, чтобы скролл работал вместе с RefreshIndicator
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            itemCount: lessonsForDay.length,
                            itemBuilder: (context, lessonIndex) {
                              final lesson = lessonsForDay[lessonIndex];
                              // Используем _LessonCard для отображения
                              return _LessonCard(lesson: lesson)
                                  .animate() // Анимация для каждой карточки
                                  .fadeIn(
                                    delay: (lessonIndex * 80).ms,
                                    duration: 300.ms,
                                  )
                                  .moveX(begin: -10, end: 0, duration: 300.ms);
                            },
                          ),
                );
              }),
            ),
      ),
    );
  }
}

// --- Виджет для отображения одной пары ---
class _LessonCard extends StatelessWidget {
  final ScheduleEntry lesson;

  const _LessonCard({required this.lesson}); // Убрали key

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCurrent =
        lesson.isCurrentLesson(); // Проверяем, идет ли пара сейчас

    return Card(
      // Используем тему CardTheme из main.dart
      margin: const EdgeInsets.only(bottom: 12.0),
      // Выделяем текущую пару рамкой
      shape:
          isCurrent
              ? RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.primary, width: 2.0),
                borderRadius: BorderRadius.circular(
                  _borderRadiusValue,
                ), // Используем общую константу
              )
              : null, // Используем форму из CardTheme, если не текущая
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Время начала и конца
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
                // Индикатор "Сейчас", если пара идет
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Chip(
                          // Используем ChipTheme из main.dart
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
                        ), // Мягкое мерцание
                  ),
              ],
            ),
            // Вертикальный разделитель
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 1.5,
                height: 50, // Примерная высота контента
                color: colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            // Информация о паре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  Row(
                    // Учитель и кабинет в строку
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lesson.teacherName ?? 'Не указан',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
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

// Не забудь определить константу _borderRadiusValue в этом файле или импортировать ее
const double _borderRadiusValue = 12.0;
