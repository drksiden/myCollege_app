import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/notification_manager.dart';

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    FirebaseFirestore.instance,
    ref.watch(notificationManagerProvider),
  );
});

class ScheduleService {
  final FirebaseFirestore _firestore;
  final NotificationManager _notificationManager;

  ScheduleService(this._firestore, this._notificationManager);

  Future<void> updateSchedule({
    required String groupId,
    required Map<String, dynamic> scheduleData,
    required String updateType,
  }) async {
    try {
      // Обновляем расписание
      await _firestore.collection('schedules').doc(groupId).set(scheduleData);

      // Отправляем уведомление
      await _notificationManager.notifyScheduleUpdate(
        groupId: groupId,
        updateType: updateType,
      );
    } catch (e) {
      print('Ошибка обновления расписания: $e');
      rethrow;
    }
  }

  Future<void> notifyUpcomingClass({
    required String groupId,
    required String subjectName,
    required String room,
    required DateTime startTime,
  }) async {
    try {
      // Отправляем уведомление о начале занятия
      await _notificationManager.notifyClassStart(
        groupId: groupId,
        subjectName: subjectName,
        room: room,
        time:
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      print('Ошибка отправки уведомления о начале занятия: $e');
      rethrow;
    }
  }
}
