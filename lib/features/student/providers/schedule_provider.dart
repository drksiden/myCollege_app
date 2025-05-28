// lib/features/student/providers/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Наши модели
import '../../../models/schedule_entry.dart';
import '../../../core/auth_service.dart';
import '../../../services/schedule_service.dart';

final scheduleServiceProvider = Provider((ref) => ScheduleService());

// Провайдер для стрима расписания текущего пользователя
final scheduleProvider = StreamProvider.autoDispose<List<ScheduleEntry>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  final scheduleService = ref.watch(scheduleServiceProvider);

  if (user == null || user.groupId == null) {
    print('DEBUG: No user or groupId found');
    return Stream.value([]);
  }

  print('DEBUG: Fetching schedule for groupId: ${user.groupId}');
  return scheduleService.getScheduleByGroup(user.groupId!).map((schedule) {
    print('DEBUG: Received schedule with ${schedule.length} entries');
    return schedule;
  });
});

// Дополнительно: Провайдер для сгруппированного расписания по дням недели
// Ключ - номер дня недели (1-7), значение - список пар на этот день
final groupedScheduleProvider =
    Provider.autoDispose<Map<int, List<ScheduleEntry>>>((ref) {
      final asyncSchedule = ref.watch(scheduleProvider);

      return asyncSchedule.maybeWhen(
        data: (scheduleList) {
          print('DEBUG: Grouping ${scheduleList.length} schedule entries');
          final grouped = <int, List<ScheduleEntry>>{};
          for (final entry in scheduleList) {
            (grouped[entry.dayOfWeek] ??= []).add(entry);
          }
          // Сортируем занятия по времени начала
          for (final dayLessons in grouped.values) {
            dayLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
          }
          print('DEBUG: Grouped into ${grouped.length} days');
          return grouped;
        },
        orElse: () {
          print('DEBUG: No schedule data available');
          return {};
        },
      );
    });
