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

          final scheduleDoc = snapshot.docs.first;
          print('DEBUG: ScheduleService: Processing schedule document');
          final data = scheduleDoc.data();
          print('DEBUG: ScheduleService: Schedule document data: $data');

          final lessons = data['lessons'] as List<dynamic>;
          print('DEBUG: ScheduleService: Found ${lessons.length} lessons');

          return lessons.map((lesson) {
            print('DEBUG: ScheduleService: Processing lesson: $lesson');
            final lessonData = lesson as Map<String, dynamic>;
            final entry = ScheduleEntry.fromJson({
              ...lessonData,
              'id': lessonData['id'],
              'groupId': groupId,
              'semester': data['semester'] ?? 1,
              'year': data['year'] ?? 2025,
            });
            print('DEBUG: ScheduleService: Created ScheduleEntry: $entry');
            return entry;
          }).toList();
        });
  }
}
