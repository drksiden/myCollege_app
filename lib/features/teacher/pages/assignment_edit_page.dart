import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/assignment.dart';
import '../../../providers/assignment_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../models/schedule_entry.dart';
import '../../../core/auth_service.dart' as auth;

class AssignmentEditPage extends ConsumerStatefulWidget {
  final Assignment? assignment;
  final String? groupId;

  const AssignmentEditPage({super.key, this.assignment, this.groupId});

  @override
  ConsumerState<AssignmentEditPage> createState() => _AssignmentEditPageState();
}

class _AssignmentEditPageState extends ConsumerState<AssignmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  String? selectedScheduleEntryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment?.title);
    _descriptionController = TextEditingController(text: widget.assignment?.description);
    _dueDate = widget.assignment?.dueDate ?? DateTime.now();
    selectedScheduleEntryId = widget.assignment?.scheduleEntryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(auth.authStateProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пользователь не авторизован')),
      );
      return;
    }

    if (widget.groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Группа не выбрана')),
      );
      return;
    }

    final assignment = Assignment(
      id: widget.assignment?.id ?? '',
      teacherId: user.uid,
      groupId: widget.groupId!,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      scheduleEntryId: selectedScheduleEntryId,
      createdAt: widget.assignment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.assignment == null) {
        await ref.read(assignmentServiceProvider).addAssignment(assignment);
      } else {
        await ref.read(assignmentServiceProvider).updateAssignment(assignment);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment == null ? 'Новое задание' : 'Редактировать задание'),
      ),
      body: StreamBuilder<List<ScheduleEntry>>(
        stream: ref.watch(scheduleProvider), // Убрали .asStream(), так как это уже Stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки расписания: ${snapshot.error}'));
          }

          final schedule = snapshot.data ?? [];
          final lessons = schedule.where((entry) => entry.groupId == widget.groupId).toList();
          if (lessons.isEmpty) {
            return const Center(child: Text('Нет доступных пар для этой группы'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButton<String>(
                  hint: const Text('Выберите пару'),
                  value: selectedScheduleEntryId,
                  isExpanded: true,
                  items: lessons.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.id,
                      child: Text('${entry.startTime} - ${entry.endTime}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedScheduleEntryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Срок сдачи'),
                  subtitle: Text(
                    '${_dueDate.day}.${_dueDate.month}.${_dueDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveAssignment,
                  child: Text(widget.assignment == null ? 'Создать' : 'Сохранить'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}