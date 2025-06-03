// lib/features/teacher/pages/grades_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../providers/teacher_grades_provider.dart';
import '../models/teacher_grades.dart';

class GradesHistoryPage extends ConsumerStatefulWidget {
  const GradesHistoryPage({super.key});

  @override
  ConsumerState<GradesHistoryPage> createState() => _GradesHistoryPageState();
}

class _GradesHistoryPageState extends ConsumerState<GradesHistoryPage> {
  String _filterSubject = 'Все';
  String _filterGradeType = 'Все';

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final gradesAsync = ref.watch(teacherGradesProvider(teacherId));
    final statsAsync = ref.watch(teacherGradesStatsProvider(teacherId));

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История оценок'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Статистика
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Статистика',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Всего оценок',
                      statsAsync['total']?.toString() ?? '0',
                      Icons.grade,
                      colorScheme,
                      textTheme,
                    ),
                    _buildStatItem(
                      'Средний балл',
                      (statsAsync['avgScore'] as double?)?.toStringAsFixed(1) ??
                          '0.0',
                      Icons.trending_up,
                      colorScheme,
                      textTheme,
                    ),
                    _buildStatItem(
                      'За неделю',
                      statsAsync['recentCount']?.toString() ?? '0',
                      Icons.today,
                      colorScheme,
                      textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Фильтры
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Предмет',
                    _filterSubject,
                    [
                      'Все',
                      ...((statsAsync['bySubject'] as Map<String, int>?)?.keys
                              .toList() ??
                          []),
                    ],
                    (value) => setState(() => _filterSubject = value!),
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    'Тип',
                    _filterGradeType,
                    ['Все', '100-балльная', 'Зачет/Незачет'],
                    (value) => setState(() => _filterGradeType = value!),
                    colorScheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Список оценок
          Expanded(
            child: gradesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки оценок',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              data: (grades) {
                if (grades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grade_outlined,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Оценок пока нет',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Выставленные вами оценки будут отображаться здесь',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Фильтрация
                final filteredGrades =
                    grades.where((grade) {
                      if (_filterSubject != 'Все' &&
                          grade.subject != _filterSubject) {
                        return false;
                      }
                      if (_filterGradeType != 'Все') {
                        final isPassFail = grade.gradeType == 'pass_fail';
                        if (_filterGradeType == 'Зачет/Незачет' &&
                            !isPassFail) {
                          return false;
                        }
                        if (_filterGradeType == '100-балльная' && isPassFail) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                if (filteredGrades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_off,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет оценок по выбранному фильтру',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Попробуйте изменить фильтры',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredGrades.length,
                  itemBuilder: (context, index) {
                    final grade = filteredGrades[index];
                    return _GradeCard(grade: grade);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
    ColorScheme colorScheme,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: value,
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}

class _GradeCard extends StatelessWidget {
  final TeacherGrade grade;

  const _GradeCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd.MM.yyyy в HH:mm', 'ru_RU');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Оценка
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: grade.getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: grade.getColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    grade.displayValue,
                    style: textTheme.titleMedium?.copyWith(
                      color: grade.getColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.subject,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Студент: ${grade.studentId}', // TODO: Заменить на имя студента
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (grade.comment != null && grade.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  grade.comment!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(grade.timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade.gradeType == 'pass_fail'
                        ? 'Зачет/Незачет'
                        : '100-балльная',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
