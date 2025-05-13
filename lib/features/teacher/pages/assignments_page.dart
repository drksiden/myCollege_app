// lib/features/teacher/pages/assignments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Для форматирования даты
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/assignment.dart';
import '../providers/assignment_service.dart'; // Для teacherAssignmentsProvider
import '../widgets/assignment_form_dialog.dart';
import '../providers/journal_providers.dart';

// TODO: Создать виджет для формы добавления/редактирования задания
// import '../widgets/assignment_form_dialog.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  String? _selectedSubject;
  String? _selectedGroupId;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(teacherAssignmentsProvider);
    final groupsAsync = ref.watch(teacherSubjectsAndGroupsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: assignmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка загрузки заданий: $err'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
          return const Center(child: SizedBox());
        },
        data: (assignments) {
          return groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка загрузки групп: $err'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
              return const Center(child: SizedBox());
            },
            data: (groups) {
              final groupMap = {for (var g in groups) g.id: g.name};
              final allSubjects =
                  groups.expand((g) => g.subjects).toSet().toList()..sort();
              final allGroups = groups;

              // --- Фильтрация ---
              var filtered =
                  assignments.where((a) {
                    final bySubject =
                        _selectedSubject == null ||
                        a.subject == _selectedSubject;
                    final byGroup =
                        _selectedGroupId == null ||
                        a.groupIds.contains(_selectedGroupId);
                    final byDate =
                        _selectedDate == null ||
                        (a.dueDate.year == _selectedDate!.year &&
                            a.dueDate.month == _selectedDate!.month &&
                            a.dueDate.day == _selectedDate!.day);
                    return bySubject && byGroup && byDate;
                  }).toList();

              return Column(
                children: [
                  Material(
                        elevation: 2,
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSubject,
                                  isExpanded: true,
                                  hint: const Text('Все предметы'),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Все предметы'),
                                    ),
                                    ...allSubjects.map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    ),
                                  ],
                                  onChanged:
                                      (v) =>
                                          setState(() => _selectedSubject = v),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedGroupId,
                                  isExpanded: true,
                                  hint: const Text('Все группы'),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Все группы'),
                                    ),
                                    ...allGroups.map(
                                      (g) => DropdownMenuItem(
                                        value: g.id,
                                        child: Text(g.name),
                                      ),
                                    ),
                                  ],
                                  onChanged:
                                      (v) =>
                                          setState(() => _selectedGroupId = v),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 120,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(Icons.event, size: 18),
                                  label: Text(
                                    _selectedDate == null
                                        ? 'Любая дата'
                                        : DateFormat.MMMd(
                                          'ru',
                                        ).format(_selectedDate!),
                                  ),
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate ?? now,
                                      firstDate: DateTime(2022),
                                      lastDate: DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      ),
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedDate = picked);
                                    }
                                  },
                                ),
                              ),
                              if (_selectedSubject != null ||
                                  _selectedGroupId != null ||
                                  _selectedDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  tooltip: 'Сбросить фильтры',
                                  onPressed:
                                      () => setState(() {
                                        _selectedSubject = null;
                                        _selectedGroupId = null;
                                        _selectedDate = null;
                                      }),
                                ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Нет заданий по выбранным фильтрам',
                          style: textTheme.bodyLarge,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filtered.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final assignment = filtered[index];
                          final groupNames = assignment.groupIds
                              .map((id) => groupMap[id] ?? id)
                              .join(', ');
                          return Card(
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  title: Text(
                                    assignment.title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      if (assignment.subject != null)
                                        Text(
                                          'Предмет: ${assignment.subject}',
                                          style: textTheme.bodySmall,
                                        ),
                                      Text(
                                        'Срок сдачи: ${DateFormat.yMMMMd('ru').add_jm().format(assignment.dueDate)}',
                                        style: textTheme.bodySmall,
                                      ),
                                      if (assignment.groupIds.isNotEmpty)
                                        Text(
                                          'Группы: $groupNames',
                                          style: textTheme.bodySmall,
                                        ),
                                      if (assignment.description != null &&
                                          assignment.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6.0,
                                          ),
                                          child: Text(
                                            assignment.description!,
                                            style: textTheme.bodySmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final edited =
                                            await AssignmentFormDialog.show(
                                              context,
                                              ref,
                                              existingAssignment: assignment,
                                            );
                                        if (edited != null) {
                                          await ref
                                              .read(assignmentServiceProvider)
                                              .updateAssignment(edited);
                                        }
                                      } else if (value == 'delete') {
                                        _showDeleteAssignmentDialog(
                                          context,
                                          ref,
                                          assignment,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Редактировать'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text(
                                                  'Удалить',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AssignmentDetailsDialog(
                                            assignment: assignment,
                                            groupNames: groupNames,
                                          ),
                                    );
                                  },
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideX(
                                begin: 0.1,
                                end: 0,
                                curve: Curves.easeOut,
                              );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await AssignmentFormDialog.show(context, ref);
          if (created != null) {
            if (created.dueDate.isAfter(DateTime.now())) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Нельзя выбрать дату в будущем'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            await ref.read(assignmentServiceProvider).addAssignment(created);
          }
        },
        child: const Icon(Icons.add_task_outlined),
        tooltip: 'Создать задание',
      ),
    );
  }

  Future<void> _showDeleteAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
    Assignment assignment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Подтверждение удаления'),
            content: Text(
              'Вы уверены, что хотите удалить задание "${assignment.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  'Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && assignment.id != null) {
      try {
        await ref
            .read(assignmentServiceProvider)
            .deleteAssignment(assignment.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задание удалено'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Провайдер teacherAssignmentsProvider обновится автоматически
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления задания: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class AssignmentDetailsDialog extends StatelessWidget {
  final Assignment assignment;
  final String groupNames;
  const AssignmentDetailsDialog({
    super.key,
    required this.assignment,
    required this.groupNames,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(assignment.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assignment.subject != null)
              Text(
                'Предмет: ${assignment.subject}',
                style: textTheme.bodyMedium,
              ),
            Text(
              'Срок сдачи: ${DateFormat.yMMMMd('ru').add_jm().format(assignment.dueDate)}',
              style: textTheme.bodyMedium,
            ),
            Text('Группы: $groupNames', style: textTheme.bodyMedium),
            if (assignment.description != null &&
                assignment.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  assignment.description!,
                  style: textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Сданные работы:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Нет сданных работ.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
