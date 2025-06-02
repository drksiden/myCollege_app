import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_entry.dart';

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
          print('DEBUG: ScheduleService: Schedule data: $scheduleData');

          // Extract lessons array from the schedule document
          final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];
          print('DEBUG: ScheduleService: Lessons array: $lessons');

          return lessons.map((lessonData) {
            print('DEBUG: ScheduleService: Processing lesson: $lessonData');
            try {
              final entry = ScheduleEntry.fromJson({
                ...lessonData,
                'id': lessonData['id'],
              });
              print('DEBUG: ScheduleService: Created ScheduleEntry: $entry');
              return entry;
            } catch (e, stackTrace) {
              print('DEBUG: ScheduleService: Error creating ScheduleEntry: $e');
              print('DEBUG: ScheduleService: Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
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
