// lib/features/student/providers/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      return asyncSchedule.when(
        data: (lessons) {
          final grouped = <int, List<ScheduleEntry>>{};
          for (var lesson in lessons) {
            grouped.putIfAbsent(lesson.dayOfWeek, () => []).add(lesson);
          }
          // Сортируем уроки по времени начала
          for (var dayLessons in grouped.values) {
            dayLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
          }
          return grouped;
        },
        loading: () => {},
        error: (_, __) => {},
      );
    });
