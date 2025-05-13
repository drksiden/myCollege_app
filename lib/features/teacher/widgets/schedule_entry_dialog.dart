import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../../../models/user.dart';
import '../providers/journal_providers.dart';
import '../providers/schedule_service.dart';
import '../../../core/auth_service.dart';

class ScheduleEntryDialog extends ConsumerStatefulWidget {
  final List<GroupInfo> availableGroups;
  final ScheduleEntry? existingEntry;
  final int
  initialDayOfWeek; // День недели для новой записи или из существующей

  const ScheduleEntryDialog({
    super.key,
    required this.availableGroups,
    this.existingEntry,
    required this.initialDayOfWeek,
  });

  // Статический метод для удобного вызова
  static Future<ScheduleEntry?> show(
    BuildContext context,
    WidgetRef
    ref, // ref передается для использования внутри диалога, если нужно
    List<GroupInfo> groups, {
    ScheduleEntry? existingEntry,
    required int
    dayOfWeekForNew, // Обязательный для новых, для старых берется из existingEntry
  }) {
    return showDialog<ScheduleEntry>(
      context: context,
      barrierDismissible: false, // Не закрывать по тапу снаружи
      builder:
          (dialogContext) => ScheduleEntryDialog(
            availableGroups: groups,
            existingEntry: existingEntry,
            initialDayOfWeek: existingEntry?.dayOfWeek ?? dayOfWeekForNew,
          ),
    );
  }

  @override
  ConsumerState<ScheduleEntryDialog> createState() =>
      _ScheduleEntryDialogState();
}

class _ScheduleEntryDialogState extends ConsumerState<ScheduleEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  // Состояние полей формы
  late int _selectedDayOfWeek;
  GroupInfo? _selectedGroup;
  int? _selectedLessonNumber;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late TextEditingController _subjectController;
  late TextEditingController _classroomController;
  late TextEditingController _lessonTypeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _selectedDayOfWeek = widget.initialDayOfWeek;
    _selectedGroup =
        entry?.groupId != null
            ? widget.availableGroups.firstWhereOrNull(
              (g) => g.id == entry!.groupId,
            )
            : (widget.availableGroups.isNotEmpty
                ? widget.availableGroups.first
                : null);
    _selectedLessonNumber = entry?.lessonNumber;
    _startTime = entry?.startTimeOfDay;
    _endTime = entry?.endTimeOfDay;
    _subjectController = TextEditingController(text: entry?.subject ?? '');
    _classroomController = TextEditingController(text: entry?.classroom ?? '');
    _lessonTypeController = TextEditingController(
      text: entry?.lessonType ?? '',
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _classroomController.dispose();
    _lessonTypeController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null ||
          _endTime == null ||
          _selectedGroup == null ||
          _selectedLessonNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Заполните все обязательные поля (время, группа, номер урока).',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Время окончания должно быть позже времени начала.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final teacher = ref.read(authStateProvider).valueOrNull;
      if (teacher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: не удалось определить учителя.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final newEntry = ScheduleEntry(
        id: widget.existingEntry?.id, // Передаем ID для обновления
        dayOfWeek: _selectedDayOfWeek,
        lessonNumber: _selectedLessonNumber!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
        subject: _subjectController.text.trim(),
        teacherId: teacher.id,
        teacherName: teacher.shortName, // Или fullName
        classroom:
            _classroomController.text.trim().isNotEmpty
                ? _classroomController.text.trim()
                : null,
        lessonType:
            _lessonTypeController.text.trim().isNotEmpty
                ? _lessonTypeController.text.trim()
                : null,
        groupId: _selectedGroup!.id,
      );

      try {
        // Проверка конфликтов перед сохранением
        final hasConflict = await ref
            .read(scheduleServiceProvider)
            .hasScheduleConflict(newEntry);
        if (hasConflict) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Конфликт расписания! Занятие в это время для этой группы уже существует.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        await ref
            .read(scheduleServiceProvider)
            .saveScheduleEntry(
              newEntry,
              isUpdate: widget.existingEntry != null,
            );
        if (mounted) {
          Navigator.of(
            context,
          ).pop(newEntry); // Возвращаем сохраненную/обновленную запись
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = [
      'Пн',
      'Вт',
      'Ср',
      'Чт',
      'Пт',
      'Сб',
      'Вс',
    ]; // Для Dropdown дня недели

    return AlertDialog(
      title: Text(
        widget.existingEntry == null
            ? 'Новое занятие'
            : 'Редактировать занятие',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // --- Выбор Группы ---
              DropdownButtonFormField<GroupInfo>(
                value: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Группа *'),
                items:
                    widget.availableGroups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(group.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedGroup = value),
                validator: (value) => value == null ? 'Выберите группу' : null,
              ),
              const SizedBox(height: 12),
              // --- Выбор дня недели ---
              DropdownButtonFormField<int>(
                value: _selectedDayOfWeek,
                decoration: const InputDecoration(labelText: 'День недели *'),
                items: List.generate(
                  dayNames.length,
                  (index) => DropdownMenuItem(
                    value: index + 1, // 1-7
                    child: Text(dayNames[index]),
                  ),
                ),
                onChanged:
                    (value) => setState(() {
                      if (value != null) _selectedDayOfWeek = value;
                    }),
                validator: (value) => value == null ? 'Выберите день' : null,
              ),
              const SizedBox(height: 12),
              // --- Номер урока ---
              TextFormField(
                initialValue: _selectedLessonNumber?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Номер урока/пары *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите номер';
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) return 'Некорректный номер';
                  return null;
                },
                onChanged:
                    (value) => _selectedLessonNumber = int.tryParse(value),
              ),
              const SizedBox(height: 12),
              // --- Время начала ---
              ListTile(
                title: Text(
                  'Начало *: ${_startTime?.format(context) ?? 'Не выбрано'}',
                ),
                trailing: const Icon(Icons.access_time),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _startTime = time);
                },
              ),
              // --- Время конца ---
              ListTile(
                title: Text(
                  'Конец *: ${_endTime?.format(context) ?? 'Не выбрано'}',
                ),
                trailing: const Icon(Icons.access_time),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _endTime = time);
                },
              ),
              const SizedBox(height: 12),
              // --- Предмет ---
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Предмет *'),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Введите предмет'
                            : null,
              ),
              const SizedBox(height: 12),
              // --- Аудитория ---
              TextFormField(
                controller: _classroomController,
                decoration: const InputDecoration(labelText: 'Аудитория'),
              ),
              const SizedBox(height: 12),
              // --- Тип занятия ---
              TextFormField(
                controller: _lessonTypeController,
                decoration: const InputDecoration(
                  labelText: 'Тип занятия (Лекция, Практика...)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(
                    widget.existingEntry == null ? 'Добавить' : 'Сохранить',
                  ),
        ),
      ],
    );
  }
}
