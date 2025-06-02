import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/schedule_entry.dart';

class ScheduleService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<ScheduleEntry>> getScheduleByGroup(String groupId) {
    print('DEBUG: ScheduleService: Getting schedule for group $groupId');
    return _firestore
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
          print(
            'DEBUG: ScheduleService: Received ${snapshot.docs.length} schedule documents',
          );
          if (snapshot.docs.isEmpty) {
            print('DEBUG: ScheduleService: No schedule documents found');
            return [];
          }

          // Get the first schedule document (there should be only one per group)
          final scheduleDoc = snapshot.docs.first;
          final scheduleData = scheduleDoc.data();

          // Extract lessons array from the schedule document
          final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];

          return lessons.map((lessonData) {
            print('DEBUG: ScheduleService: Processing lesson: $lessonData');
            final entry = ScheduleEntry.fromJson({
              ...lessonData,
              'id': lessonData['id'],
            });
            print('DEBUG: ScheduleService: Created ScheduleEntry: $entry');
            return entry;
          }).toList();
        });
  }

  // Добавить новое занятие
  Future<void> addScheduleEntry(ScheduleEntry entry) async {
    // First, get the schedule document for the group
    final scheduleQuery =
        await _firestore
            .collection('schedules')
            .where('groupId', isEqualTo: entry.groupId)
            .get();

    if (scheduleQuery.docs.isEmpty) {
      // Create new schedule document if it doesn't exist
      await _firestore.collection('schedules').add({
        'groupId': entry.groupId,
        'groupName': '',
        'lessons': [
          {
            'id': entry.id,
            'dayOfWeek': entry.dayOfWeek,
            'startTime': entry.startTime,
            'endTime': entry.endTime,
            'duration': entry.duration ?? 90,
            'subjectId': entry.subjectId,
            'teacherId': entry.teacherId,
            'room': entry.room,
            'type': entry.type,
            'weekType': entry.weekType,
            'isFloating': entry.isFloating ?? false,
            'semesterId': entry.semesterId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        ],
        'semester': 1,
        'semesterId': entry.semesterId,
        'year': DateTime.now().year,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing schedule document
      final scheduleDoc = scheduleQuery.docs.first;
      final scheduleData = scheduleDoc.data();
      final lessons = List<Map<String, dynamic>>.from(
        scheduleData['lessons'] ?? [],
      );

      lessons.add({
        'id': entry.id,
        'dayOfWeek': entry.dayOfWeek,
        'startTime': entry.startTime,
        'endTime': entry.endTime,
        'duration': entry.duration ?? 90,
        'subjectId': entry.subjectId,
        'teacherId': entry.teacherId,
        'room': entry.room,
        'type': entry.type,
        'weekType': entry.weekType,
        'isFloating': entry.isFloating ?? false,
        'semesterId': entry.semesterId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await scheduleDoc.reference.update({
        'lessons': lessons,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Обновить занятие
  Future<void> updateScheduleEntry(ScheduleEntry entry) async {
    final scheduleQuery =
        await _firestore
            .collection('schedules')
            .where('groupId', isEqualTo: entry.groupId)
            .get();

    if (scheduleQuery.docs.isEmpty) {
      throw Exception('Schedule not found for group ${entry.groupId}');
    }

    final scheduleDoc = scheduleQuery.docs.first;
    final scheduleData = scheduleDoc.data();
    final lessons = List<Map<String, dynamic>>.from(
      scheduleData['lessons'] ?? [],
    );

    final lessonIndex = lessons.indexWhere(
      (lesson) => lesson['id'] == entry.id,
    );
    if (lessonIndex == -1) {
      throw Exception('Lesson not found with id ${entry.id}');
    }

    lessons[lessonIndex] = {
      'id': entry.id,
      'dayOfWeek': entry.dayOfWeek,
      'startTime': entry.startTime,
      'endTime': entry.endTime,
      'duration': entry.duration ?? 90,
      'subjectId': entry.subjectId,
      'teacherId': entry.teacherId,
      'room': entry.room,
      'type': entry.type,
      'weekType': entry.weekType,
      'isFloating': entry.isFloating ?? false,
      'semesterId': entry.semesterId,
      'createdAt': lessons[lessonIndex]['createdAt'],
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await scheduleDoc.reference.update({
      'lessons': lessons,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Удалить занятие
  Future<void> deleteScheduleEntry(String entryId, String groupId) async {
    final scheduleQuery =
        await _firestore
            .collection('schedules')
            .where('groupId', isEqualTo: groupId)
            .get();

    if (scheduleQuery.docs.isEmpty) {
      throw Exception('Schedule not found for group $groupId');
    }

    final scheduleDoc = scheduleQuery.docs.first;
    final scheduleData = scheduleDoc.data();
    final lessons = List<Map<String, dynamic>>.from(
      scheduleData['lessons'] ?? [],
    );

    lessons.removeWhere((lesson) => lesson['id'] == entryId);

    await scheduleDoc.reference.update({
      'lessons': lessons,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ScheduleEntry>> getTeacherSchedule(String teacherId) {
    print('DEBUG: ScheduleService: Getting schedule for teacher $teacherId');
    return _firestore.collection('schedules').snapshots().map((snapshot) {
      print(
        'DEBUG: ScheduleService: Received ${snapshot.docs.length} schedule documents',
      );
      if (snapshot.docs.isEmpty) {
        print('DEBUG: ScheduleService: No schedule documents found');
        return [];
      }

      // Collect all lessons from all schedules where teacherId matches
      final allLessons = <ScheduleEntry>[];

      for (final scheduleDoc in snapshot.docs) {
        final scheduleData = scheduleDoc.data();
        final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];

        for (final lessonData in lessons) {
          if (lessonData['teacherId'] == teacherId) {
            final entry = ScheduleEntry.fromJson({
              ...lessonData,
              'id': lessonData['id'],
            });
            allLessons.add(entry);
          }
        }
      }

      return allLessons;
    });
  }
}
