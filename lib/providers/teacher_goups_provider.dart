// lib/providers/teacher_groups_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart'; // Используем основную модель Group
import '../providers/group_provider.dart';
import '../features/teacher/providers/teacher_schedule_provider.dart';

// Провайдер для получения групп конкретного преподавателя
// на основе его расписания
final teacherGroupsProvider = FutureProvider.family<List<Group>, String>((
  ref,
  teacherId,
) async {
  print('DEBUG: teacherGroupsProvider: Getting groups for teacher $teacherId');

  // Получаем расписание преподавателя
  final schedule = await ref.watch(teacherScheduleProvider(teacherId).future);

  // Извлекаем уникальные ID групп из расписания
  final groupIds = schedule.map((lesson) => lesson.groupId).toSet().toList();
  print('DEBUG: teacherGroupsProvider: Found group IDs: $groupIds');

  if (groupIds.isEmpty) {
    print('DEBUG: teacherGroupsProvider: No groups found in schedule');
    return [];
  }

  // Загружаем полную информацию о группах
  final groups = <Group>[];
  for (final groupId in groupIds) {
    try {
      final group = await ref.read(groupProvider(groupId).future);
      if (group != null) {
        groups.add(group);
        print('DEBUG: teacherGroupsProvider: Added group: ${group.name}');
      } else {
        print('DEBUG: teacherGroupsProvider: Group not found for ID: $groupId');
      }
    } catch (e) {
      print('DEBUG: teacherGroupsProvider: Error loading group $groupId: $e');
    }
  }

  // Сортируем группы по названию
  groups.sort((a, b) => a.name.compareTo(b.name));

  print('DEBUG: teacherGroupsProvider: Final groups count: ${groups.length}');
  return groups;
});

// Провайдер для получения названий групп преподавателя (для упрощенного отображения)
final teacherGroupNamesProvider = FutureProvider.family<List<String>, String>((
  ref,
  teacherId,
) async {
  final groups = await ref.watch(teacherGroupsProvider(teacherId).future);
  return groups.map((group) => group.name).toList();
});

// Провайдер для получения групп преподавателя с дополнительной информацией
final teacherGroupsWithInfoProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      teacherId,
    ) async {
      final groups = await ref.watch(teacherGroupsProvider(teacherId).future);

      return groups
          .map(
            (group) => {
              'group': group,
              'displayName':
                  '${group.name} (${group.specialization} ${group.year} курс)',
              'shortName': group.name,
            },
          )
          .toList();
    });
