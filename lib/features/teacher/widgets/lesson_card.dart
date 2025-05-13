import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../../../models/user.dart';
import '../providers/journal_providers.dart';
import '../providers/schedule_service.dart';
import '../providers/teacher_schedule_provider.dart';
import '../../../core/auth_service.dart';
import 'schedule_entry_dialog.dart';

const double _borderRadiusValue = 12.0;

class LessonCard extends ConsumerWidget {
  final ScheduleEntry lesson;
  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCurrent = lesson.isCurrentLesson();

    final groupsInfoAsync = ref.watch(teacherSubjectsAndGroupsProvider);
    String displayGroupName = lesson.groupId ?? 'ID группы не указан';

    if (lesson.groupId != null &&
        groupsInfoAsync is AsyncData<List<GroupInfo>>) {
      final groupInfo = groupsInfoAsync.value.firstWhereOrNull(
        (info) => info.id == lesson.groupId,
      );
      if (groupInfo != null) {
        displayGroupName = groupInfo.name;
      } else {
        displayGroupName = 'Группа (${lesson.groupId!.substring(0, 5)}...)';
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        shape:
            isCurrent
                ? RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(_borderRadiusValue),
                )
                : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadiusValue),
          onTap: () async {
            final action = await showDialog<String>(
              context: context,
              builder:
                  (dialogContext) => AlertDialog(
                    title: const Text('Действие с занятием'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: const Text('Редактировать'),
                          onTap: () => Navigator.of(dialogContext).pop('edit'),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                          title: Text(
                            'Удалить',
                            style: TextStyle(color: colorScheme.error),
                          ),
                          onTap:
                              () => Navigator.of(dialogContext).pop('delete'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Отмена'),
                      ),
                    ],
                  ),
            );

            if (action == 'edit') {
              final groups = await ref.read(
                teacherSubjectsAndGroupsProvider.future,
              );
              if (!context.mounted || groups.isEmpty) {
                if (context.mounted && groups.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Нет доступных групп для выбора.'),
                    ),
                  );
                }
                return;
              }

              final result = await ScheduleEntryDialog.show(
                context,
                ref,
                groups,
                existingEntry: lesson,
                dayOfWeekForNew: lesson.dayOfWeek,
              );

              if (result != null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Занятие обновлено'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(teacherScheduleProvider);
              }
            } else if (action == 'delete') {
              if (lesson.id == null || lesson.groupId == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Невозможно удалить: отсутствует ID занятия или группы.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      title: const Text('Подтверждение'),
                      content: const Text(
                        'Вы уверены, что хотите удалить это занятие?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(true),
                          child: Text(
                            'Удалить',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                try {
                  await ref
                      .read(scheduleServiceProvider)
                      .deleteScheduleEntry(lesson.id!);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Занятие удалено'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(teacherScheduleProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка удаления: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        lesson.startTime,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isCurrent
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color:
                            isCurrent
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      Text(
                        lesson.endTime,
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              isCurrent
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: 1.0,
                            child: Chip(
                              label: const Text('ИДЕТ'),
                              backgroundColor: colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: 1.5,
                    height: 50,
                    color: colorScheme.outlineVariant.withAlpha(128),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.subject,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (lesson.lessonType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lesson.lessonType!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (lesson.groupId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 14,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayGroupName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      if (lesson.classroom != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
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
        ),
      ),
    );
  }
}
