// lib/features/teacher/widgets/attendance_view_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

// Провайдеры
import '../providers/journal_providers.dart';
// Модели
import '../../../models/user.dart';
import '../../../models/attendance_record.dart';

class AttendanceViewWidget extends ConsumerWidget {
  final List<User> students;
  final GroupInfo selectedGroupInfo;
  final String selectedSubject;
  final DateTime selectedDate;
  final int selectedLessonNumber; // Урок теперь выбран

  const AttendanceViewWidget({
    super.key,
    required this.students,
    required this.selectedGroupInfo,
    required this.selectedSubject,
    required this.selectedDate,
    required this.selectedLessonNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return const Center(child: Text('В выбранной группе нет студентов.'));
    }

    // Получаем данные о посещаемости для выбранного урока
    final attendanceAsync = ref.watch(
      attendanceProvider((
        groupId: selectedGroupInfo.id,
        date: selectedDate,
        lessonNumber: selectedLessonNumber,
      )),
    );

    return attendanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, st) =>
              Center(child: Text('Ошибка загрузки посещаемости: $err')),
      data: (records) {
        // Группируем записи по studentId для быстрого доступа
        final recordsByStudent = groupBy<AttendanceRecord, String>(
          records,
          (r) => r.studentId,
        );

        // Строим список студентов со статусами
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 80), // Отступ для FAB
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final student = students[index];
            // Находим запись о посещаемости для этого студента (может быть null)
            final record =
                recordsByStudent[student.id]
                    ?.firstOrNull; // Берем первую, если вдруг дубликаты
            final status =
                record?.status ??
                AttendanceStatus.absentInvalid; // По умолчанию - пропуск
            final statusDisplay = _getStatusDisplay(
              status,
            ); // Используем хелпер
            final statusColor = _getStatusColor(context, status);
            final statusIcon = _getStatusIcon(status);

            return ListTile(
              title: Text(
                student.fullName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Tooltip(
                // Добавляем подсказку
                message: _getStatusTooltip(status),
                child: InkWell(
                  onTap: () {
                    _showAttendanceStatusDialog(
                      context,
                      ref,
                      student,
                      selectedGroupInfo,
                      selectedSubject,
                      selectedDate,
                      selectedLessonNumber,
                      record,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Chip(
                    label: Text(
                      statusDisplay,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    avatar: Icon(statusIcon, color: statusColor, size: 18),
                    backgroundColor: statusColor.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    side: BorderSide.none,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Хелперы для отображения статуса ---
  String _getStatusDisplay(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'П';
      case AttendanceStatus.absentValid:
        return 'У';
      case AttendanceStatus.absentInvalid:
        return 'Н';
      case AttendanceStatus.late:
        return 'О';
    }
  }

  String _getStatusTooltip(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Присутствовал';
      case AttendanceStatus.absentValid:
        return 'Уваж. причина';
      case AttendanceStatus.absentInvalid:
        return 'Пропуск';
      case AttendanceStatus.late:
        return 'Опоздание';
    }
  }

  Color _getStatusColor(BuildContext context, AttendanceStatus status) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.shade600;
      case AttendanceStatus.absentValid:
        return Colors.orange.shade700;
      case AttendanceStatus.absentInvalid:
        return colors.error;
      case AttendanceStatus.late:
        return Colors.blue.shade600;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absentValid:
        return Icons.help_outline;
      case AttendanceStatus.absentInvalid:
        return Icons.cancel_outlined;
      case AttendanceStatus.late:
        return Icons.watch_later_outlined;
    }
  }
  // -------------------------------------

  // --- Диалог изменения статуса посещаемости ---
  Future<void> _showAttendanceStatusDialog(
    BuildContext context,
    WidgetRef ref, // Передаем context и ref
    User student,
    GroupInfo selectedGroupInfo,
    String selectedSubject,
    DateTime selectedDate,
    int selectedLessonNumber,
    AttendanceRecord? currentRecord,
  ) async {
    final journalService = ref.read(journalServiceProvider);
    final statuses = AttendanceStatus.values; // Все возможные статусы

    AttendanceStatus? selectedStatus = await showDialog<AttendanceStatus>(
      context: context,
      builder: (dialogContext) {
        // Используем dialogContext
        String? reason = currentRecord?.reason ?? ''; // Для ввода причины
        final reasonController = TextEditingController(text: reason);

        return AlertDialog(
          title: Text("Статус: ${student.shortName}"),
          content: SingleChildScrollView(
            // Добавляем прокрутку
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...statuses.map((status) {
                  // Используем spread operator
                  return RadioListTile<AttendanceStatus>(
                    title: Text(
                      _getStatusTooltip(status),
                    ), // Используем полное название
                    secondary: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(context, status),
                    ),
                    value: status,
                    groupValue: currentRecord?.status,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (value) => Navigator.of(
                          dialogContext,
                        ).pop(value), // Закрываем при выборе
                  );
                }).toList(),
                // Поле для ввода причины (показываем для У и Н)
                if (currentRecord?.status == AttendanceStatus.absentValid ||
                    currentRecord?.status == AttendanceStatus.absentInvalid ||
                    // Показываем и если выбран новый статус У или Н
                    (selectedStatus == AttendanceStatus.absentValid ||
                        selectedStatus == AttendanceStatus.absentInvalid))
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Причина отсутствия (необязательно)',
                        hintText: 'Например, "Болел(а)"',
                      ),
                      onChanged:
                          (value) =>
                              reason = value, // Обновляем причину при вводе
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            // Кнопку "Сохранить" можно убрать, так как выбор в RadioListTile сразу закрывает диалог
          ],
        );
      },
    );

    if (selectedStatus != null) {
      final recordToSave = AttendanceRecord(
        studentId: student.id,
        studentName: student.shortName,
        groupId: selectedGroupInfo.id,
        date: selectedDate,
        lessonNumber: selectedLessonNumber,
        subject: selectedSubject,
        status: selectedStatus,
        // Сохраняем причину, только если статус У или Н
        reason:
            (selectedStatus == AttendanceStatus.absentValid ||
                    selectedStatus == AttendanceStatus.absentInvalid)
                ? currentRecord
                    ?.reason // TODO: Передавать введенную причину из диалога
                : null,
        recordedByTeacherId: '', // Будет установлено в JournalService
        timestamp: DateTime.now(),
      );
      try {
        await journalService.addOrUpdateAttendanceRecord(recordToSave);
        // Не нужно явно показывать SnackBar, UI обновится через провайдер
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка обновления статуса: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ------------------------------------------
}
