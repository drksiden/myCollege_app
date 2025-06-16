import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigation {
  final BuildContext context;

  NotificationNavigation(this.context);

  // Обработка нажатия на уведомление
  void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'message':
        _handleMessageNotification(data);
        break;
      case 'schedule_update':
        _handleScheduleNotification(data);
        break;
      case 'grade':
        _handleGradeNotification(data);
        break;
      case 'homework':
        _handleHomeworkNotification(data);
        break;
      case 'announcement':
        _handleAnnouncementNotification(data);
        break;
      case 'class_start':
        _handleClassStartNotification(data);
        break;
      case 'deadline':
        _handleDeadlineNotification(data);
        break;
    }
  }

  // Обработка уведомления о сообщении
  void _handleMessageNotification(Map<String, dynamic> data) {
    final senderName = data['senderName'] as String?;
    if (senderName != null) {
      // Переходим в чат с отправителем
      context.push('/chat/$senderName');
    }
  }

  // Обработка уведомления о расписании
  void _handleScheduleNotification(Map<String, dynamic> data) {
    final groupId = data['groupId'] as String?;
    if (groupId != null) {
      // Переходим к расписанию группы
      context.push('/schedule/group/$groupId');
    }
  }

  // Обработка уведомления об оценке
  void _handleGradeNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    if (subjectName != null) {
      // Переходим к оценкам по предмету
      context.push('/grades/subject/$subjectName');
    }
  }

  // Обработка уведомления о домашнем задании
  void _handleHomeworkNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    if (subjectName != null) {
      // Переходим к домашним заданиям по предмету
      context.push('/homework/subject/$subjectName');
    }
  }

  // Обработка уведомления об объявлении
  void _handleAnnouncementNotification(Map<String, dynamic> data) {
    // Переходим к списку объявлений
    context.push('/announcements');
  }

  // Обработка уведомления о начале занятия
  void _handleClassStartNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final room = data['room'] as String?;
    if (subjectName != null && room != null) {
      // Переходим к расписанию с выделенным занятием
      context.push('/schedule/class/$subjectName/$room');
    }
  }

  // Обработка уведомления о дедлайне
  void _handleDeadlineNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final taskName = data['taskName'] as String?;
    if (subjectName != null && taskName != null) {
      // Переходим к заданию
      context.push('/homework/task/$subjectName/$taskName');
    }
  }
}
