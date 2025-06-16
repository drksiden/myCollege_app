// lib/features/student/providers/schedule_provider.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../../models/schedule_entry.dart';
import '../../../models/semester.dart';
import '../../../core/auth_service.dart';
import '../../../services/schedule_service.dart';
import '../../../services/semester_service.dart';
import '../../../models/subject.dart';
import '../../../models/teacher.dart';

final logger = Logger();

final scheduleServiceProvider = Provider((ref) => ScheduleService());
final semesterServiceProvider = Provider((ref) => SemesterService());

// Провайдер для текущего семестра
final currentSemesterProvider = StreamProvider<Semester?>((ref) {
  return ref.watch(semesterServiceProvider).getCurrentSemester();
});

// Провайдер для выбранного семестра (по умолчанию - текущий)
final selectedSemesterProvider = StateProvider<Semester?>((ref) {
  final currentSemester = ref.watch(currentSemesterProvider).valueOrNull;
  logger.d('Selected semester: ${currentSemester?.name}');
  return currentSemester;
});

// Основной провайдер для расписания студента
final studentScheduleProvider = StreamProvider.autoDispose<
  List<ScheduleEntry>
>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  final scheduleService = ref.watch(scheduleServiceProvider);
  final selectedSemester = ref.watch(selectedSemesterProvider);

  logger.d('StudentScheduleProvider: Auth state: ${user?.email}');
  logger.d(
    'StudentScheduleProvider: Selected semester: ${selectedSemester?.name}',
  );
  logger.d('StudentScheduleProvider: User groupId: ${user?.groupId}');

  // Проверяем наличие пользователя и группы
  if (user == null) {
    logger.d('StudentScheduleProvider: No authenticated user');
    return Stream.value([]);
  }

  if (user.groupId == null || user.groupId!.isEmpty) {
    logger.d('StudentScheduleProvider: User has no groupId');
    return Stream.value([]);
  }

  // Если семестр не выбран, используем текущий
  if (selectedSemester == null) {
    logger.d(
      'StudentScheduleProvider: No semester selected, waiting for current semester',
    );

    // Получаем текущий семестр и затем расписание
    return ref.watch(currentSemesterProvider).whenData((currentSemester) {
          if (currentSemester == null) {
            logger.d('StudentScheduleProvider: No current semester found');
            return Stream.value(<ScheduleEntry>[]);
          }

          logger.d(
            'StudentScheduleProvider: Using current semester: ${currentSemester.name}',
          );

          // Возвращаем стрим расписания для текущего семестра
          return scheduleService.getScheduleByGroupAndSemester(
            user.groupId!,
            currentSemester,
          );
        }).value ??
        Stream.value(<ScheduleEntry>[]);
  }

  logger.d(
    'StudentScheduleProvider: Fetching schedule for groupId: ${user.groupId} and semester: ${selectedSemester.name}',
  );
  return scheduleService.getScheduleByGroupAndSemester(
    user.groupId!,
    selectedSemester,
  );
});

// Провайдер для группировки расписания по дням недели
final groupedStudentScheduleProvider = Provider.autoDispose<
  Map<int, List<ScheduleEntry>>
>((ref) {
  final asyncSchedule = ref.watch(studentScheduleProvider);

  logger.d(
    'DEBUG: GroupedStudentScheduleProvider: Schedule state: ${asyncSchedule.valueOrNull?.length} entries',
  );

  return asyncSchedule.when(
    data: (lessons) {
      logger.d(
        'DEBUG: GroupedStudentScheduleProvider: Processing ${lessons.length} lessons',
      );

      final grouped = <int, List<ScheduleEntry>>{};

      // Инициализируем все дни недели
      for (var i = 1; i <= 7; i++) {
        grouped[i] = [];
      }

      // Группируем уроки по дням
      for (final lesson in lessons) {
        if (lesson.dayOfWeek >= 1 && lesson.dayOfWeek <= 7) {
          grouped[lesson.dayOfWeek]?.add(lesson);
        } else {
          logger.d(
            'DEBUG: GroupedStudentScheduleProvider: Invalid dayOfWeek: ${lesson.dayOfWeek}',
          );
        }
      }

      // Сортируем уроки в каждом дне по времени
      for (final dayLessons in grouped.values) {
        dayLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      logger.d(
        'DEBUG: GroupedStudentScheduleProvider: Grouped lessons by day: ${grouped.map((k, v) => MapEntry(k, v.length))}',
      );
      return grouped;
    },
    loading: () {
      logger.d('DEBUG: GroupedStudentScheduleProvider: Loading state');
      return <int, List<ScheduleEntry>>{};
    },
    error: (error, stack) {
      logger.d('DEBUG: GroupedStudentScheduleProvider: Error state: $error');
      return <int, List<ScheduleEntry>>{};
    },
  );
});

// Провайдер для получения расписания на сегодня
final todayScheduleProvider = Provider.autoDispose<List<ScheduleEntry>>((ref) {
  final groupedSchedule = ref.watch(groupedStudentScheduleProvider);
  final today = DateTime.now().weekday; // 1 = понедельник, 7 = воскресенье

  final todayLessons = groupedSchedule[today] ?? [];
  logger.d(
    'DEBUG: TodayScheduleProvider: Found ${todayLessons.length} lessons for today (day $today)',
  );

  return todayLessons;
});

// Провайдер для получения следующего урока
final nextLessonProvider = Provider.autoDispose<ScheduleEntry?>((ref) {
  final todayLessons = ref.watch(todayScheduleProvider);
  final now = TimeOfDay.fromDateTime(DateTime.now());
  final nowMinutes = now.hour * 60 + now.minute;

  for (final lesson in todayLessons) {
    final lessonStart = lesson.startTimeOfDay;
    if (lessonStart != null) {
      final lessonStartMinutes = lessonStart.hour * 60 + lessonStart.minute;
      if (lessonStartMinutes > nowMinutes) {
        logger.d(
          'DEBUG: NextLessonProvider: Next lesson at ${lesson.startTime}',
        );
        return lesson;
      }
    }
  }

  logger.d('DEBUG: NextLessonProvider: No more lessons today');
  return null;
});

// Провайдер для получения текущего урока
final currentLessonProvider = Provider.autoDispose<ScheduleEntry?>((ref) {
  final todayLessons = ref.watch(todayScheduleProvider);

  for (final lesson in todayLessons) {
    if (lesson.isCurrentLesson()) {
      logger.d(
        'DEBUG: CurrentLessonProvider: Current lesson: ${lesson.startTime}-${lesson.endTime}',
      );
      return lesson;
    }
  }

  logger.d('DEBUG: CurrentLessonProvider: No current lesson');
  return null;
});

// Провайдер для статистики расписания
final scheduleStatsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final asyncSchedule = ref.watch(studentScheduleProvider);

  return asyncSchedule.when(
    data: (lessons) {
      final stats = <String, dynamic>{
        'totalLessons': lessons.length,
        'lessonsByDay': <int, int>{},
        'lessonsByType': <String, int>{},
        'uniqueSubjects': <String>{},
        'uniqueTeachers': <String>{},
      };

      // Подсчет по дням
      for (var i = 1; i <= 7; i++) {
        stats['lessonsByDay'][i] = 0;
      }

      for (final lesson in lessons) {
        // По дням
        stats['lessonsByDay'][lesson.dayOfWeek] =
            (stats['lessonsByDay'][lesson.dayOfWeek] as int) + 1;

        // По типам
        stats['lessonsByType'][lesson.type] =
            (stats['lessonsByType'][lesson.type] as int? ?? 0) + 1;

        // Уникальные предметы и преподаватели
        (stats['uniqueSubjects'] as Set<String>).add(lesson.subjectId);
        (stats['uniqueTeachers'] as Set<String>).add(lesson.teacherId);
      }

      // Конвертируем Set в count
      stats['uniqueSubjectsCount'] = (stats['uniqueSubjects'] as Set).length;
      stats['uniqueTeachersCount'] = (stats['uniqueTeachers'] as Set).length;

      return stats;
    },
    loading:
        () => <String, dynamic>{
          'totalLessons': 0,
          'lessonsByDay': <int, int>{},
          'lessonsByType': <String, int>{},
          'uniqueSubjectsCount': 0,
          'uniqueTeachersCount': 0,
        },
    error:
        (_, __) => <String, dynamic>{
          'totalLessons': 0,
          'lessonsByDay': <int, int>{},
          'lessonsByType': <String, int>{},
          'uniqueSubjectsCount': 0,
          'uniqueTeachersCount': 0,
        },
  );
});

// Провайдер для получения расписания
final scheduleProvider = StreamProvider<List<ScheduleEntry>>((ref) {
  return FirebaseFirestore.instance.collection('schedule').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => ScheduleEntry.fromJson(doc.data()))
        .where((entry) => entry.isValid)
        .toList();
  });
});

// Провайдер для получения сгруппированного расписания по дням недели
final groupedScheduleProvider = Provider<Map<int, List<ScheduleEntry>>>((ref) {
  final scheduleAsync = ref.watch(scheduleProvider);

  return scheduleAsync.when(
    data: (schedule) {
      final grouped = <int, List<ScheduleEntry>>{};
      for (var i = 1; i <= 7; i++) {
        grouped[i] = [];
      }

      for (final entry in schedule) {
        if (entry.isValid && entry.isCurrentWeek()) {
          grouped[entry.dayOfWeek]?.add(entry);
        }
      }

      // Сортировка по времени начала
      for (final day in grouped.keys) {
        grouped[day]?.sort((a, b) {
          final aStart = a.startTimeOfDay;
          final bStart = b.startTimeOfDay;
          if (aStart == null || bStart == null) return 0;
          return aStart.hour * 60 +
              aStart.minute -
              (bStart.hour * 60 + bStart.minute);
        });
      }

      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Провайдер для получения имени преподавателя по ID
final teacherNameByIdProvider = FutureProvider.family<String, String>((
  ref,
  teacherId,
) async {
  // Сначала получаем учителя
  final teacherDoc =
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .get();

  if (!teacherDoc.exists) return 'Неизвестный преподаватель';

  final teacher = Teacher.fromJson({
    ...teacherDoc.data()!,
    'id': teacherDoc.id,
  });

  // Затем получаем информацию о пользователе
  final userDoc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(teacher.userId)
          .get();

  if (!userDoc.exists) return 'Неизвестный преподаватель';

  final userData = userDoc.data()!;
  return '${userData['lastName'] ?? ''} ${userData['firstName'] ?? ''} ${userData['middleName'] ?? ''}'
      .trim();
});

// Провайдер для получения названия предмета по ID
final subjectNameByIdProvider = FutureProvider.family<String, String>((
  ref,
  subjectId,
) async {
  final doc =
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .get();

  if (!doc.exists) return 'Неизвестный предмет';

  final subject = Subject.fromJson(doc.data()!);
  return subject.name;
});
