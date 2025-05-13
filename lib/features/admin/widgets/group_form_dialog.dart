import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/admin/pages/admin_groups_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/group.dart';
import '../providers/admin_groups_provider.dart' show teacherListProvider;
import '../../../models/user.dart' as app_user;

class GroupFormDialog extends ConsumerStatefulWidget {
  final Group? group;
  final void Function(Group group)? onSave;
  const GroupFormDialog({super.key, this.group, this.onSave});

  @override
  ConsumerState<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends ConsumerState<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _courseController;
  String? _selectedTeacherId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _specialtyController = TextEditingController(
      text: widget.group?.specialty ?? '',
    );
    _courseController = TextEditingController(
      text: widget.group?.course?.toString() ?? '',
    );
    _selectedTeacherId = widget.group?.teacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final group = Group(
      id: widget.group?.id,
      name: _nameController.text.trim(),
      specialty: _specialtyController.text.trim(),
      course: int.tryParse(_courseController.text.trim()) ?? 1,
      teacherId: _selectedTeacherId ?? '',
      teacherName: null, // Можно заполнить позже
      subjects: widget.group?.subjects ?? [], // Заглушка
    );
    widget.onSave?.call(group);
    Navigator.of(context).pop(group);
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(teacherListProvider);
    return AlertDialog(
      title: Text(
        widget.group == null ? 'Создать группу' : 'Редактировать группу',
      ),
      content: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Ошибка загрузки учителей: $err'),
        data:
            (teachers) => Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название группы',
                      ),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Введите название'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Специальность',
                      ),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Введите специальность'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(labelText: 'Курс'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 6)
                          return 'Введите курс (1-6)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Без куратора'),
                        ),
                        ...teachers.map(
                          (app_user.User t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              t.fullName != null && t.fullName!.isNotEmpty
                                  ? t.fullName!
                                  : '${t.lastName ?? ''} ${t.firstName ?? ''}${t.patronymic != null && t.patronymic!.isNotEmpty ? ' ${t.patronymic}' : ''}',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedTeacherId = v),
                      decoration: const InputDecoration(labelText: 'Куратор'),
                    ),
                  ],
                ),
              ),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.group == null ? 'Создать' : 'Сохранить'),
        ),
      ],
    );
  }
}
