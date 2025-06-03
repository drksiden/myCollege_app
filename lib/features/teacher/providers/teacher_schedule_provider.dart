import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../../../services/schedule_service.dart';

// Провайдер для получения расписания учителя
final teacherScheduleProvider = FutureProvider.family<
  List<ScheduleEntry>,
  String
>((ref, teacherId) async {
  print(
    'DEBUG: teacherScheduleProvider: Getting schedule for teacher $teacherId',
  );
  final scheduleService = ScheduleService();
  final scheduleStream = scheduleService.getTeacherSchedule(teacherId);

  // Преобразуем Stream в Future и удаляем дубликаты
  final lessons = await scheduleStream.first;
  print('DEBUG: teacherScheduleProvider: Received ${lessons.length} lessons');

  final uniqueLessons = <String, ScheduleEntry>{};
  for (final lesson in lessons) {
    uniqueLessons[lesson.id] = lesson;
  }

  print(
    'DEBUG: teacherScheduleProvider: After deduplication: ${uniqueLessons.length} lessons',
  );
  return uniqueLessons.values.toList();
});

// Провайдер для получения дней недели с уроками
final teacherScheduleDaysProvider = Provider.family<List<int>, String>((
  ref,
  teacherId,
) {
  final scheduleAsync = ref.watch(teacherScheduleProvider(teacherId));

  return scheduleAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (lessons) {
      final days = lessons.map((l) => l.dayOfWeek).toSet().toList();
      days.sort();
      print('DEBUG: teacherScheduleDaysProvider: Available days: $days');
      return days;
    },
  );
});
