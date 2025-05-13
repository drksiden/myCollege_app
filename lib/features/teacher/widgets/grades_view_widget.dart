// lib/features/teacher/widgets/grades_view_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

// Провайдеры
import '../providers/journal_providers.dart'; // Нужен JournalService
// Модели
import '../../../models/user.dart';
import '../../../models/grade.dart';
import '../../../models/attendance_record.dart'; // Хоть и не используется напрямую, но для единообразия импортов

class GradesViewWidget extends ConsumerWidget {
  final List<User> students;
  final List<Grade> allGradesForSubject;
  final GroupInfo selectedGroupInfo; // Нужен для groupId
  final String selectedSubject; // Нужен для subject
  final DateTime selectedDateForDialog; // Для даты по умолчанию в диалоге

  const GradesViewWidget({
    super.key,
    required this.students,
    required this.allGradesForSubject,
    required this.selectedGroupInfo,
    required this.selectedSubject,
    required this.selectedDateForDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return const Center(child: Text('В выбранной группе нет студентов.'));
    }

    // Группируем оценки по studentId для быстрого доступа
    final gradesByStudent = groupBy<Grade, String>(
      allGradesForSubject,
      (g) => g.studentId,
    );

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Отступ снизу для FAB
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = students[index];
        final studentGrades = gradesByStudent[student.id] ?? [];

        return ListTile(
          title: Text(
            student.fullName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle:
              studentGrades.isEmpty
                  ? Text(
                    'Нет оценок',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  )
                  : SizedBox(
                    height: 45,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children:
                            studentGrades
                                .map(
                                  (grade) => Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: InkWell(
                                      onTap: () {
                                        _showAddEditGradeDialog(
                                          context,
                                          ref,
                                          student,
                                          selectedGroupInfo,
                                          selectedSubject,
                                          selectedDateForDialog,
                                          grade,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Chip(
                                        label: Text(
                                          grade.grade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: grade.getColor(context),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        backgroundColor: grade
                                            .getColor(context)
                                            .withOpacity(0.1),
                                        side: BorderSide(
                                          color: grade
                                              .getColor(context)
                                              .withOpacity(0.3),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
          trailing: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Добавить оценку',
            onPressed: () {
              _showAddEditGradeDialog(
                context,
                ref,
                student,
                selectedGroupInfo,
                selectedSubject,
                selectedDateForDialog,
              );
            },
          ),
        );
      },
    );
  }

  // Диалог добавления/редактирования ОЦЕНКИ
  Future<void> _showAddEditGradeDialog(
    BuildContext context, // Передаем BuildContext
    WidgetRef ref, // Передаем WidgetRef
    User student,
    GroupInfo selectedGroupInfo,
    String selectedSubject,
    DateTime selectedDateForDialog, [ // Используем эту дату по умолчанию
    Grade? existingGrade,
  ]) async {
    final _formKey = GlobalKey<FormState>();
    final gradeController = TextEditingController(
      text: existingGrade?.grade ?? '',
    );
    final commentController = TextEditingController(
      text: existingGrade?.comment ?? '',
    );
    String? selectedGradeType = existingGrade?.gradeType;
    DateTime dateOfGrade =
        existingGrade?.date ??
        selectedDateForDialog; // Инициализируем датой из фильтра или существующей оценки

    final List<String> gradeTypes = [
      'Обычная',
      'Контрольная',
      'Экзамен',
      'Домашняя работа',
      'Зачет',
      'Незачет',
    ];

    Grade? result = await showDialog<Grade>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Используем dialogContext
        return StatefulBuilder(
          builder: (sfbContext, setDialogState) {
            return AlertDialog(
              title: Text(
                existingGrade == null
                    ? 'Новая оценка: ${student.shortName}'
                    : 'Редакт. оценки: ${student.shortName}',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: gradeController,
                        decoration: const InputDecoration(
                          labelText: 'Оценка (5, 4, Зч, Нз...)',
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Введите оценку'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGradeType,
                        decoration: const InputDecoration(
                          labelText: 'Тип оценки',
                        ),
                        items:
                            gradeTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setDialogState(() => selectedGradeType = value),
                        validator:
                            (value) => (value == null) ? 'Выберите тип' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Комментарий (необязательно)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Дата: ${DateFormat.yMd('ru').format(dateOfGrade)}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext, // Используем dialogContext
                            initialDate: dateOfGrade,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (picked != null && picked != dateOfGrade) {
                            setDialogState(() => dateOfGrade = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final grade = Grade(
                        studentId: student.id,
                        studentName: student.shortName,
                        groupId: selectedGroupInfo.id,
                        subject: selectedSubject,
                        grade: gradeController.text.trim(),
                        gradeType: selectedGradeType,
                        comment:
                            commentController.text.trim().isNotEmpty
                                ? commentController.text.trim()
                                : null,
                        date: dateOfGrade,
                        teacherId: '', // Будет установлено в сервисе
                        teacherName: '',
                        // gradeId: existingGrade?.id, // TODO: Для обновления оценки
                      );
                      Navigator.of(dialogContext).pop(grade);
                    }
                  },
                  child: Text(existingGrade == null ? 'Добавить' : 'Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final journalService = ref.read(journalServiceProvider);
      try {
        await journalService.addOrUpdateGrade(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Оценка сохранена'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения оценки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
