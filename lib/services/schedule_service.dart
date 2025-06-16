// lib/services/schedule_service.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_entry.dart';
import '../models/semester.dart';
import 'semester_service.dart';

class ScheduleService {
  final _firestore = FirebaseFirestore.instance;
  final _semesterService = SemesterService();

  // Получить расписание для группы (текущий семестр)
  Stream<List<ScheduleEntry>> getScheduleByGroup(String groupId) {
    print('DEBUG: ScheduleService: Getting schedule for group $groupId');

    if (groupId.isEmpty) {
      print('DEBUG: ScheduleService: Empty groupId');
      return Stream.value([]);
    }

    return _semesterService.getCurrentSemester().asyncMap((semester) async {
      if (semester == null) {
        print('DEBUG: ScheduleService: No active semester found');
        return <ScheduleEntry>[];
      }

      print('DEBUG: ScheduleService: Using semester: ${semester.name}');
      return _getScheduleForGroupAndSemester(groupId, semester.id);
    });
  }

  // Получить расписание для группы и семестра
  Stream<List<ScheduleEntry>> getScheduleByGroupAndSemester(
    String groupId,
    Semester semester,
  ) {
    print(
      'DEBUG: ScheduleService: Getting schedule for group $groupId and semester ${semester.name}',
    );

    if (groupId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .where('semesterId', isEqualTo: semester.id)
        .snapshots()
        .asyncMap((snapshot) async {
          return _processScheduleSnapshot(snapshot, groupId, semester.id);
        });
  }

  // Получить расписание для преподавателя
  Stream<List<ScheduleEntry>> getTeacherSchedule(String teacherId) {
    print('DEBUG: ScheduleService: Getting schedule for teacher $teacherId');

    if (teacherId.isEmpty) {
      print('DEBUG: ScheduleService: Empty teacherId');
      return Stream.value([]);
    }

    return _firestore.collection('schedules').snapshots().asyncMap((
      snapshot,
    ) async {
      print(
        'DEBUG: ScheduleService: Processing ${snapshot.docs.length} schedule documents for teacher',
      );

      final allLessons = <ScheduleEntry>[];
      final seenKeys = <String>{}; // Для дедупликации

      for (final scheduleDoc in snapshot.docs) {
        final scheduleData = scheduleDoc.data();
        final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];

        for (final lessonData in lessons) {
          if (lessonData['teacherId'] == teacherId) {
            try {
              // Создаем уникальный ключ для дедупликации
              final uniqueKey = _createUniqueKey(lessonData);

              if (!seenKeys.contains(uniqueKey)) {
                seenKeys.add(uniqueKey);
                final entry = _createScheduleEntry(lessonData);
                if (entry != null && entry.isValid) {
                  allLessons.add(entry);
                  print(
                    'DEBUG: ScheduleService: Added lesson for teacher: ${entry.id}',
                  );
                }
              } else {
                print('DEBUG: ScheduleService: Skipping duplicate lesson');
              }
            } catch (e) {
              print('DEBUG: ScheduleService: Error parsing teacher lesson: $e');
            }
          }
        }
      }

      // Сортируем по дню недели и времени
      allLessons.sort((a, b) {
        final dayComparison = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayComparison != 0) return dayComparison;
        return a.startTime.compareTo(b.startTime);
      });

      print(
        'DEBUG: ScheduleService: Total teacher lessons: ${allLessons.length}',
      );
      return allLessons;
    });
  }

  // Приватные методы

  Future<List<ScheduleEntry>> _getScheduleForGroupAndSemester(
    String groupId,
    String semesterId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('schedules')
              .where('groupId', isEqualTo: groupId)
              .where('semesterId', isEqualTo: semesterId)
              .get();

      return _processScheduleSnapshot(snapshot, groupId, semesterId);
    } catch (e) {
      print('DEBUG: ScheduleService: Error getting schedule: $e');
      return [];
    }
  }

  List<ScheduleEntry> _processScheduleSnapshot(
    QuerySnapshot snapshot,
    String groupId,
    String semesterId,
  ) {
    print(
      'DEBUG: ScheduleService: Processing ${snapshot.docs.length} schedule documents',
    );

    if (snapshot.docs.isEmpty) {
      print('DEBUG: ScheduleService: No schedule documents found');
      return [];
    }

    final allLessons = <ScheduleEntry>[];
    final seenKeys = <String>{}; // Для дедупликации

    for (final scheduleDoc in snapshot.docs) {
      final scheduleData = scheduleDoc.data() as Map<String, dynamic>;
      final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];

      print(
        'DEBUG: ScheduleService: Processing ${lessons.length} lessons from document ${scheduleDoc.id}',
      );

      for (final lessonData in lessons) {
        try {
          // Создаем уникальный ключ для дедупликации
          final uniqueKey = _createUniqueKey(lessonData);

          if (!seenKeys.contains(uniqueKey)) {
            seenKeys.add(uniqueKey);
            final entry = _createScheduleEntry(lessonData, groupId, semesterId);
            if (entry != null && entry.isValid) {
              allLessons.add(entry);
              print('DEBUG: ScheduleService: Added lesson: ${entry.id}');
            } else {
              print('DEBUG: ScheduleService: Invalid lesson data');
            }
          } else {
            print('DEBUG: ScheduleService: Skipping duplicate lesson');
          }
        } catch (e) {
          print('DEBUG: ScheduleService: Error processing lesson: $e');
          print('DEBUG: ScheduleService: Lesson data: $lessonData');
        }
      }
    }

    // Сортируем по дню недели и времени
    allLessons.sort((a, b) {
      final dayComparison = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayComparison != 0) return dayComparison;
      return a.startTime.compareTo(b.startTime);
    });

    print('DEBUG: ScheduleService: Final lessons count: ${allLessons.length}');
    return allLessons;
  }

  ScheduleEntry? _createScheduleEntry(
    Map<String, dynamic> lessonData, [
    String? groupId,
    String? semesterId,
  ]) {
    try {
      // Подготавливаем данные с проверками
      final processedData = <String, dynamic>{
        'id': lessonData['id']?.toString() ?? _generateLessonId(lessonData),
        'groupId': lessonData['groupId']?.toString() ?? groupId ?? '',
        'semesterId': lessonData['semesterId']?.toString() ?? semesterId ?? '',
        'subjectId': lessonData['subjectId']?.toString() ?? '',
        'teacherId': lessonData['teacherId']?.toString() ?? '',
        'startTime': lessonData['startTime']?.toString() ?? '',
        'endTime': lessonData['endTime']?.toString() ?? '',
        'dayOfWeek': _safeInt(lessonData['dayOfWeek'], 1),
        'type': lessonData['type']?.toString() ?? 'lecture',
        'weekType': lessonData['weekType']?.toString() ?? 'all',
        'room': lessonData['room']?.toString() ?? '',
        'duration': _safeInt(lessonData['duration'], 90),
        'isFloating': lessonData['isFloating'] ?? false,
        'createdAt': lessonData['createdAt'],
        'updatedAt': lessonData['updatedAt'],
      };

      // Проверяем обязательные поля
      if (processedData['groupId'].toString().isEmpty ||
          processedData['subjectId'].toString().isEmpty ||
          processedData['teacherId'].toString().isEmpty ||
          processedData['startTime'].toString().isEmpty ||
          processedData['endTime'].toString().isEmpty) {
        print('DEBUG: ScheduleService: Missing required fields in lesson data');
        return null;
      }

      return ScheduleEntry.fromJson(processedData);
    } catch (e) {
      print('DEBUG: ScheduleService: Error creating ScheduleEntry: $e');
      return null;
    }
  }

  String _createUniqueKey(Map<String, dynamic> lessonData) {
    return '${lessonData['dayOfWeek']}_${lessonData['startTime']}_${lessonData['endTime']}_${lessonData['subjectId']}_${lessonData['groupId']}_${lessonData['teacherId']}';
  }

  String _generateLessonId(Map<String, dynamic> lessonData) {
    // Генерируем ID на основе данных урока
    final components = [
      lessonData['groupId']?.toString() ?? '',
      lessonData['subjectId']?.toString() ?? '',
      lessonData['dayOfWeek']?.toString() ?? '',
      lessonData['startTime']?.toString() ?? '',
    ];
    return components.join('_');
  }

  int _safeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
