// lib/core/notification_navigation.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigation {
  final BuildContext context;

  NotificationNavigation(this.context);

  // Обработка нажатия на уведомление
  void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null) {
      debugPrint('Notification type is null');
      return;
    }

    debugPrint('Handling notification tap: $type');
    debugPrint('Notification data: $data');

    try {
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
        case 'assignment':
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
        case 'attendance':
          _handleAttendanceNotification(data);
          break;
        case 'news':
          _handleNewsNotification(data);
          break;
        default:
          debugPrint('Unknown notification type: $type');
          _handleDefaultNotification();
      }
    } catch (e) {
      debugPrint('Error handling notification: $e');
      _handleDefaultNotification();
    }
  }

  // Обработка уведомления о сообщении
  void _handleMessageNotification(Map<String, dynamic> data) {
    final senderId = data['senderId'] as String?;
    final senderName = data['senderName'] as String?;
    final chatId = data['chatId'] as String?;

    if (chatId != null) {
      // Переходим к конкретному чату
      _navigateTo('/chat/$chatId');
    } else if (senderId != null) {
      // Переходим к списку чатов с этим пользователем
      _navigateTo('/home'); // Переходим на главную, затем к чатам
    } else {
      // Переходим к общему списку чатов
      _navigateTo('/home');
    }
  }

  // Обработка уведомления о расписании
  void _handleScheduleNotification(Map<String, dynamic> data) {
    final groupId = data['groupId'] as String?;
    if (groupId != null) {
      // Переходим к расписанию конкретной группы
      _navigateTo('/home/schedule');
    } else {
      // Переходим к общему расписанию
      _navigateTo('/home');
    }
  }

  // Обработка уведомления об оценке
  void _handleGradeNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final gradeId = data['gradeId'] as String?;

    // Переходим к оценкам
    _navigateTo('/home'); // Затем к вкладке оценок
  }

  // Обработка уведомления о домашнем задании
  void _handleHomeworkNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final assignmentId = data['assignmentId'] as String?;

    // Переходим к заданиям
    _navigateTo('/home'); // Затем к соответствующей секции
  }

  // Обработка уведомления об объявлении
  void _handleAnnouncementNotification(Map<String, dynamic> data) {
    final announcementId = data['announcementId'] as String?;

    // Переходим к объявлениям
    _navigateTo('/home'); // Затем к новостям
  }

  // Обработка уведомления о начале занятия
  void _handleClassStartNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final room = data['room'] as String?;
    final time = data['time'] as String?;

    // Переходим к расписанию
    _navigateTo('/home/schedule');
  }

  // Обработка уведомления о дедлайне
  void _handleDeadlineNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;
    final taskName = data['taskName'] as String?;
    final deadline = data['deadline'] as String?;

    // Переходим к заданиям
    _navigateTo('/home');
  }

  // Обработка уведомления о посещаемости
  void _handleAttendanceNotification(Map<String, dynamic> data) {
    final subjectName = data['subjectName'] as String?;

    // Переходим к посещаемости
    _navigateTo('/home/attendance');
  }

  // Обработка уведомления о новостях
  void _handleNewsNotification(Map<String, dynamic> data) {
    final newsId = data['newsId'] as String?;

    // Переходим к новостям
    _navigateTo('/home'); // Затем к вкладке новостей
  }

  // Обработка по умолчанию
  void _handleDefaultNotification() {
    _navigateTo('/home');
  }

  // Безопасная навигация
  void _navigateTo(String path) {
    try {
      if (context.mounted) {
        context.go(path);
      }
    } catch (e) {
      debugPrint('Navigation error to $path: $e');
      // Fallback навигация
      try {
        if (context.mounted) {
          context.go('/home');
        }
      } catch (fallbackError) {
        debugPrint('Fallback navigation error: $fallbackError');
      }
    }
  }
}
