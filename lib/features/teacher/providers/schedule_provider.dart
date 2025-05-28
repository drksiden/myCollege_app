import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../services/schedule_service.dart';
import '../../../core/auth_service.dart';

final scheduleServiceProvider = Provider((ref) => ScheduleService());

final teacherScheduleProvider = StreamProvider.autoDispose<List<ScheduleEntry>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final scheduleService = ref.watch(scheduleServiceProvider);

    if (user == null) {
      return Stream.value([]);
    }

    return scheduleService.getTeacherSchedule(user.id);
  },
);

final groupScheduleProvider = StreamProvider.autoDispose
    .family<List<ScheduleEntry>, String>((ref, groupId) {
      final scheduleService = ref.watch(scheduleServiceProvider);
      return scheduleService.getGroupSchedule(groupId);
    });

// Провайдер для сгруппированного расписания по дням недели
final groupedTeacherScheduleProvider =
    Provider.autoDispose<Map<int, List<ScheduleEntry>>>((ref) {
      final asyncSchedule = ref.watch(teacherScheduleProvider);

      return asyncSchedule.maybeWhen(
        data: (scheduleList) {
          final grouped = <int, List<ScheduleEntry>>{};
          for (final entry in scheduleList) {
            (grouped[entry.dayOfWeek] ??= []).add(entry);
          }
          // Сортируем занятия по времени начала
          for (final dayLessons in grouped.values) {
            dayLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
          }
          return grouped;
        },
        orElse: () => {},
      );
    });
