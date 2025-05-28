import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/schedule_entry.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Получить расписание группы
  Stream<List<ScheduleEntry>> getGroupSchedule(String groupId) {
    return _db
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .orderBy('dayOfWeek')
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ScheduleEntry.fromJson({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }

  // Добавить новое занятие
  Future<void> addScheduleEntry(ScheduleEntry entry) async {
    await _db.collection('schedules').add({
      'groupId': entry.groupId,
      'dayOfWeek': entry.dayOfWeek,
      'duration': entry.duration,
      'startTime': entry.startTime,
      'endTime': entry.endTime,
      'subjectId': entry.subjectId,
      'teacherId': entry.teacherId,
      'room': entry.room,
      'type': entry.type,
      'weekType': entry.weekType,
      'isFloating': entry.isFloating,
      'semester': entry.semester,
      'year': entry.year,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновить занятие
  Future<void> updateScheduleEntry(ScheduleEntry entry) async {
    await _db.collection('schedules').doc(entry.id).update({
      'groupId': entry.groupId,
      'dayOfWeek': entry.dayOfWeek,
      'duration': entry.duration,
      'startTime': entry.startTime,
      'endTime': entry.endTime,
      'subjectId': entry.subjectId,
      'teacherId': entry.teacherId,
      'room': entry.room,
      'type': entry.type,
      'weekType': entry.weekType,
      'isFloating': entry.isFloating,
      'semester': entry.semester,
      'year': entry.year,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Удалить занятие
  Future<void> deleteScheduleEntry(String entryId) async {
    await _db.collection('schedules').doc(entryId).delete();
  }

  // Получить расписание преподавателя
  Stream<List<ScheduleEntry>> getTeacherSchedule(String teacherId) {
    return _db
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('dayOfWeek')
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ScheduleEntry.fromJson({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }
}
