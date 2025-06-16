import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

// Провайдер для менеджера уведомлений
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager(ref.watch(notificationServiceProvider));
});

class NotificationManager {
  final NotificationService _notificationService;

  NotificationManager(this._notificationService);

  // Уведомление о новом сообщении
  Future<void> notifyNewMessage({
    required String recipientId,
    required String senderName,
    required String messagePreview,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: recipientId,
      title: 'Новое сообщение от $senderName',
      body: messagePreview,
      data: {'type': 'message', 'senderName': senderName},
    );
  }

  // Уведомление об обновлении расписания
  Future<void> notifyScheduleUpdate({
    required String groupId,
    required String updateType,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Обновление расписания',
      body: 'Расписание было обновлено: $updateType',
      data: {
        'type': 'schedule_update',
        'groupId': groupId,
        'updateType': updateType,
      },
    );
  }

  // Уведомление о новой оценке
  Future<void> notifyNewGrade({
    required String studentId,
    required String subjectName,
    required String grade,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: studentId,
      title: 'Новая оценка',
      body: 'По предмету "$subjectName" получена оценка: $grade',
      data: {'type': 'grade', 'subjectName': subjectName, 'grade': grade},
    );
  }

  // Уведомление о новом домашнем задании
  Future<void> notifyNewHomework({
    required String groupId,
    required String subjectName,
    required String deadline,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Новое домашнее задание',
      body: 'По предмету "$subjectName". Срок сдачи: $deadline',
      data: {
        'type': 'homework',
        'subjectName': subjectName,
        'deadline': deadline,
      },
    );
  }

  // Уведомление о важном объявлении
  Future<void> notifyAnnouncement({
    required String title,
    required String body,
    String? role,
  }) async {
    if (role != null) {
      // Отправляем уведомление пользователям с определенной ролью
      await _notificationService.sendNotificationToRole(
        role: role,
        title: title,
        body: body,
        data: {'type': 'announcement', 'role': role},
      );
    } else {
      // Отправляем уведомление всем пользователям
      await _notificationService.sendNotificationToTopic(
        topic: 'announcements',
        title: title,
        body: body,
        data: {'type': 'announcement'},
      );
    }
  }

  // Уведомление о начале занятия
  Future<void> notifyClassStart({
    required String groupId,
    required String subjectName,
    required String room,
    required String time,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Начало занятия',
      body: '$subjectName в аудитории $room через 5 минут ($time)',
      data: {
        'type': 'class_start',
        'subjectName': subjectName,
        'room': room,
        'time': time,
      },
    );
  }

  // Уведомление о дедлайне
  Future<void> notifyDeadline({
    required String groupId,
    required String subjectName,
    required String taskName,
    required String deadline,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Приближается дедлайн',
      body:
          'Задание "$taskName" по предмету "$subjectName" нужно сдать до $deadline',
      data: {
        'type': 'deadline',
        'subjectName': subjectName,
        'taskName': taskName,
        'deadline': deadline,
      },
    );
  }
}
