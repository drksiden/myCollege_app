// lib/models/lesson.dart
import 'package:flutter/material.dart'; // Для TimeOfDay

class Lesson {
  final String subject;
  final String teacher;
  final String timeRange; // 'HH:mm - HH:mm'
  final String? room; // Добавим кабинет (опционально)
  final IconData? icon; // Добавим иконку (опционально)

  Lesson({
    required this.subject,
    required this.teacher,
    required this.timeRange,
    this.room,
    this.icon,
  });

  // Хелпер для получения TimeOfDay начала и конца урока
  // Возвращает null, если формат времени некорректен
  ({TimeOfDay? start, TimeOfDay? end})? parseTimeRange() {
    try {
      final parts = timeRange.split(' - ');
      if (parts.length != 2) return null;

      final startTimeParts = parts[0].split(':');
      final endTimeParts = parts[1].split(':');
      if (startTimeParts.length != 2 || endTimeParts.length != 2) return null;

      final startHour = int.tryParse(startTimeParts[0]);
      final startMinute = int.tryParse(startTimeParts[1]);
      final endHour = int.tryParse(endTimeParts[0]);
      final endMinute = int.tryParse(endTimeParts[1]);

      if (startHour == null ||
          startMinute == null ||
          endHour == null ||
          endMinute == null) {
        return null;
      }

      return (
        start: TimeOfDay(hour: startHour, minute: startMinute),
        end: TimeOfDay(hour: endHour, minute: endMinute),
      );
    } catch (e) {
      print("Error parsing time range '$timeRange': $e");
      return null;
    }
  }
}
