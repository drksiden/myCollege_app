import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_providers.dart';

class ScheduleFilters extends ConsumerWidget {
  final String? selectedGroupId;
  final String? selectedSubject;
  final Function(String?) onGroupChanged;
  final Function(String?) onSubjectChanged;

  const ScheduleFilters({
    super.key,
    required this.selectedGroupId,
    required this.selectedSubject,
    required this.onGroupChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final asyncGroupsInfo = ref.watch(teacherSubjectsAndGroupsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Фильтры',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          asyncGroupsInfo.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Ошибка загрузки групп: $error'),
            data: (groups) {
              // Получаем уникальные предметы из всех групп
              final subjects =
                  groups.expand((group) => group.subjects).toSet().toList()
                    ..sort();

              return Row(
                children: [
                  // Фильтр по группе
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Группа',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Все группы'),
                        ),
                        ...groups.map((group) {
                          return DropdownMenuItem(
                            value: group.id,
                            child: Text(group.name),
                          );
                        }),
                      ],
                      onChanged: onGroupChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Фильтр по предмету
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Предмет',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Все предметы'),
                        ),
                        ...subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }),
                      ],
                      onChanged: onSubjectChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
