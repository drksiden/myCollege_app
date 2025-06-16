import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    required String senderId,
    required String senderName,
    required String messagePreview,
    String? chatId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: recipientId,
      title: 'Новое сообщение от $senderName',
      body: messagePreview,
      data: {
        'type': 'message',
        'senderId': senderId,
        'senderName': senderName,
        'chatId': chatId,
      },
    );
  }

  // Уведомление об обновлении расписания
  Future<void> notifyScheduleUpdate({
    required String groupId,
    required String updateType,
    String? subjectName,
    String? time,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Обновление расписания',
      body: _getScheduleUpdateMessage(updateType, subjectName, time),
      data: {
        'type': 'schedule_update',
        'groupId': groupId,
        'updateType': updateType,
        'subjectName': subjectName,
        'time': time,
      },
    );
  }

  // Уведомление о новой оценке
  Future<void> notifyNewGrade({
    required String studentId,
    required String subjectName,
    required String grade,
    required String teacherName,
    String? gradeType,
    String? comment,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: studentId,
      title: 'Новая оценка',
      body: 'По предмету "$subjectName" получена оценка: $grade',
      data: {
        'type': 'grade',
        'subjectName': subjectName,
        'grade': grade,
        'teacherName': teacherName,
        'gradeType': gradeType,
        'comment': comment,
      },
    );
  }

  // Уведомление о новом домашнем задании
  Future<void> notifyNewHomework({
    required String groupId,
    required String subjectName,
    required String taskTitle,
    required String deadline,
    String? description,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Новое домашнее задание',
      body: 'По предмету "$subjectName": $taskTitle. Срок сдачи: $deadline',
      data: {
        'type': 'homework',
        'subjectName': subjectName,
        'taskTitle': taskTitle,
        'deadline': deadline,
        'description': description,
      },
    );
  }

  // Уведомление о важном объявлении
  Future<void> notifyAnnouncement({
    required String title,
    required String body,
    String? role,
    String? groupId,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'type': 'announcement',
      'role': role,
      'groupId': groupId,
      ...?additionalData,
    };

    if (groupId != null) {
      // Отправляем уведомление конкретной группе
      await _notificationService.sendNotificationToTopic(
        topic: 'group_$groupId',
        title: title,
        body: body,
        data: data,
      );
    } else if (role != null) {
      // Отправляем уведомление пользователям с определенной ролью
      await _notificationService.sendNotificationToRole(
        role: role,
        title: title,
        body: body,
        data: data,
      );
    } else {
      // Отправляем уведомление всем пользователям
      await _notificationService.sendNotificationToTopic(
        topic: 'announcements',
        title: title,
        body: body,
        data: data,
      );
    }
  }

  // Уведомление о начале занятия
  Future<void> notifyClassStart({
    required String groupId,
    required String subjectName,
    required String room,
    required String time,
    String? teacherName,
  }) async {
    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Начало занятия',
      body: 'Сейчас начинается $subjectName в аудитории $room',
      data: {
        'type': 'class_start',
        'groupId': groupId,
        'subjectName': subjectName,
        'room': room,
        'time': time,
        'teacherName': teacherName,
      },
    );
  }

  // Уведомление о приближающемся дедлайне
  Future<void> notifyDeadline({
    required String groupId,
    required String subjectName,
    required String taskName,
    required String deadline,
    String? description,
    int? hoursLeft,
  }) async {
    final timeLeft =
        hoursLeft != null ? '$hoursLeft ${_getHoursText(hoursLeft)}' : 'скоро';

    await _notificationService.sendNotificationToTopic(
      topic: 'group_$groupId',
      title: 'Приближается дедлайн',
      body:
          'Задание "$taskName" по предмету "$subjectName" нужно сдать $timeLeft',
      data: {
        'type': 'deadline',
        'groupId': groupId,
        'subjectName': subjectName,
        'taskName': taskName,
        'deadline': deadline,
        'description': description,
        'hoursLeft': hoursLeft,
      },
    );
  }

  // Вспомогательный метод для форматирования сообщения об обновлении расписания
  String _getScheduleUpdateMessage(
    String updateType,
    String? subjectName,
    String? time,
  ) {
    final subject = subjectName != null ? ' по предмету "$subjectName"' : '';
    final timeStr = time != null ? ' в $time' : '';

    switch (updateType) {
      case 'added':
        return 'Добавлено новое занятие$subject$timeStr';
      case 'changed':
        return 'Изменено занятие$subject$timeStr';
      case 'cancelled':
        return 'Отменено занятие$subject$timeStr';
      case 'moved':
        return 'Перенесено занятие$subject$timeStr';
      default:
        return 'Обновлено расписание$subject$timeStr';
    }
  }

  // Вспомогательный метод для склонения слова "час"
  String _getHoursText(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) {
      return 'час';
    } else if (hours % 10 >= 2 &&
        hours % 10 <= 4 &&
        (hours % 100 < 10 || hours % 100 >= 20)) {
      return 'часа';
    } else {
      return 'часов';
    }
  }
}
