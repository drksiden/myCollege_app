import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/assignment.dart';
import '../providers/journal_providers.dart';

class AssignmentFormDialog extends ConsumerStatefulWidget {
  final Assignment? existingAssignment;
  const AssignmentFormDialog({super.key, this.existingAssignment});

  static Future<Assignment?> show(
    BuildContext context,
    WidgetRef ref, {
    Assignment? existingAssignment,
  }) async {
    return showDialog<Assignment>(
      context: context,
      builder:
          (ctx) => AssignmentFormDialog(existingAssignment: existingAssignment),
    );
  }

  @override
  ConsumerState<AssignmentFormDialog> createState() =>
      _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends ConsumerState<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  String? _subject;
  List<String> _selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    final a = widget.existingAssignment;
    _titleController = TextEditingController(text: a?.title ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _dueDate = a?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _subject = a?.subject;
    _selectedGroupIds = List<String>.from(a?.groupIds ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGroups = ref.watch(teacherSubjectsAndGroupsProvider);
    return AlertDialog(
      title: Text(
        widget.existingAssignment == null
            ? 'Новое задание'
            : 'Редактировать задание',
      ),
      content: asyncGroups.when(
        loading:
            () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (err, _) => Text('Ошибка загрузки групп: $err'),
        data: (groups) {
          final allSubjects =
              groups.expand((g) => g.subjects).toSet().toList()..sort();
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название задания',
                    ),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Введите название'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _subject,
                    items:
                        allSubjects
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _subject = v),
                    decoration: const InputDecoration(labelText: 'Предмет'),
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? 'Выберите предмет' : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _dueDate ??
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _dueDate ?? DateTime.now(),
                          ),
                        );
                        if (time != null) {
                          setState(() {
                            _dueDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Срок сдачи',
                      ),
                      child: Row(
                        children: [
                          Text(
                            _dueDate != null
                                ? DateFormat.yMMMMd(
                                  'ru',
                                ).add_jm().format(_dueDate!)
                                : 'Выберите дату',
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_outlined, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Группы'),
                    child: Wrap(
                      spacing: 8,
                      children:
                          groups.map((g) {
                            final selected = _selectedGroupIds.contains(g.id);
                            return FilterChip(
                              label: Text(g.name),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _selectedGroupIds.add(g.id);
                                  } else {
                                    _selectedGroupIds.remove(g.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            if (_dueDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выберите срок сдачи')),
              );
              return;
            }
            if (_selectedGroupIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выберите хотя бы одну группу')),
              );
              return;
            }
            final assignment = Assignment(
              id: widget.existingAssignment?.id,
              title: _titleController.text.trim(),
              description:
                  _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
              dueDate: _dueDate!,
              createdAt: widget.existingAssignment?.createdAt ?? DateTime.now(),
              teacherId: widget.existingAssignment?.teacherId ?? '',
              teacherName: widget.existingAssignment?.teacherName,
              groupIds: _selectedGroupIds,
              subject: _subject,
              attachments: widget.existingAssignment?.attachments ?? [],
              maxPoints: widget.existingAssignment?.maxPoints,
            );
            Navigator.of(context).pop(assignment);
          },
          child: Text(
            widget.existingAssignment == null ? 'Создать' : 'Сохранить',
          ),
        ),
      ],
    );
  }
}
