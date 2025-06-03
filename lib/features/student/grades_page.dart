// lib/features/student/grades_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // <-- Импортируем intl для форматирования даты

import '../../models/grade.dart'; // Наша модель Grade
import 'providers/grades_provider.dart'; // Наши провайдеры

// Используем ConsumerStatefulWidget для хранения выбранного фильтра
class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  // Локальное состояние для выбранного предмета в фильтре
  String _selectedSubject = 'Все';

  // Функция для получения отфильтрованного списка оценок
  List<Grade> _getFilteredGrades(List<Grade> allGrades) {
    if (_selectedSubject == 'Все') {
      return allGrades; // Уже отсортированы в провайдере по дате
    }
    return allGrades.where((g) => g.subject == _selectedSubject).toList();
  }

  // Функция для расчета среднего балла (только для числовых оценок)
  String _calculateAverage(List<Grade> filteredGrades) {
    // Отбираем только те оценки, которые можно преобразовать в число
    final numericGrades =
        filteredGrades
            .map((g) => g.numericGrade) // Используем getter из модели
            .whereType<double>() // Отбрасываем null (нечисловые оценки)
            .toList();

    if (numericGrades.isEmpty) {
      // Если числовых оценок нет, можем показать прочерк или 0.0
      return '--';
    }

    final sum = numericGrades.reduce((a, b) => a + b);
    final average = sum / numericGrades.length;

    // Можно добавить логику округления или форматирования
    return average.toStringAsFixed(1); // Округляем до 1 знака после запятой
  }

  @override
  Widget build(BuildContext context) {
    // Следим за асинхронным состоянием оценок
    final asyncGrades = ref.watch(gradesProvider);
    // Получаем список уникальных предметов для фильтра
    final uniqueSubjects = ref.watch(uniqueSubjectsProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оценки'),
        // Можно добавить кнопку для сброса фильтра
        actions: [
          if (_selectedSubject != 'Все')
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Сбросить фильтр',
              onPressed: () => setState(() => _selectedSubject = 'Все'),
            ),
        ],
      ),
      body: Column(
        children: [
          // --- Фильтр по предметам ---
          Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Предмет',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  items:
                      uniqueSubjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedSubject = value);
                  },
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.1), // Анимация фильтра
          // --- Список оценок (или индикаторы) ---
          Expanded(
            child: asyncGrades.when(
              // --- Загрузка ---
              loading: () => const Center(child: CircularProgressIndicator()),
              // --- Ошибка ---
              error: (error, stack) {
                debugPrint('Error loading grades: $error\n$stack');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Ошибка загрузки оценок.\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              // --- Данные ---
              data: (allGrades) {
                final filteredGrades = _getFilteredGrades(allGrades);
                final average = _calculateAverage(filteredGrades);
                final bool hasGradesToShow = filteredGrades.isNotEmpty;

                // Используем AnimatedSwitcher для плавной смены списка/сообщения
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child:
                      hasGradesToShow
                          ? Column(
                            // Добавляем Column для списка и среднего балла
                            key: ValueKey(
                              'grades_list_$_selectedSubject',
                            ), // Ключ меняется при смене фильтра
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: filteredGrades.length,
                                  itemBuilder: (context, index) {
                                    final grade = filteredGrades[index];
                                    return _GradeListTile(grade: grade)
                                        .animate()
                                        .fadeIn(
                                          delay: (index * 50).ms,
                                          duration: 250.ms,
                                        )
                                        .moveX(begin: -10, duration: 250.ms);
                                  },
                                ),
                              ),
                              Padding(
                                // Отображение среднего балла под списком
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  'Средняя оценка: $average',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().scale(
                                  delay: 100.ms,
                                ), // Анимация среднего балла
                              ),
                            ],
                          )
                          : Center(
                            // Сообщение, если оценок нет
                            key: const ValueKey('no_grades'),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child:
                                  Text(
                                    _selectedSubject == 'Все'
                                        ? 'У вас пока нет оценок'
                                        : 'Нет оценок по предмету "$_selectedSubject"',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(),
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
}

// --- Виджет для отображения одной оценки в списке ---
class _GradeListTile extends StatefulWidget {
  final Grade grade;
  const _GradeListTile({required this.grade});

  @override
  State<_GradeListTile> createState() => _GradeListTileState();
}

class _GradeListTileState extends State<_GradeListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'ru_RU',
    ).format(widget.grade.date);
    final gradeColor = widget.grade.getColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: gradeColor.withAlpha(30),
                foregroundColor: gradeColor,
                child: const Icon(Icons.star_outline, size: 20),
              ),
              title: Text(widget.grade.subject),
              subtitle: Text(
                '${widget.grade.isPassFail ? "Зачет" : "Оценка"} • $formattedDate',
                style: textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.grade.isPassFail
                            ? (widget.grade.value == 'pass'
                                ? 'Зачет'
                                : 'Незачет')
                            : widget.grade.value.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.grade.teacher.isNotEmpty)
                        Text(
                          widget.grade.teacher,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            if (_isExpanded &&
                (widget.grade.comment != null || widget.grade.semester != null))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.grade.comment != null &&
                        widget.grade.comment!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.grade.comment!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.grade.semester != null)
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Семестр: ${widget.grade.semester}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
