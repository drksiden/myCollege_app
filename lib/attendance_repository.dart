import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AttendanceRepository {
  static final AttendanceRepository _instance = AttendanceRepository._internal();
  factory AttendanceRepository() => _instance;

  final Map<String, List<Map<String, dynamic>>> monthlyAttendance = {};
  final List<DateTime> holidays = [
    DateTime(2025, 1, 1),
    DateTime(2025, 3, 8),
    DateTime(2025, 5, 9),
  ];

  AttendanceRepository._internal() {
    _generateAttendance();
  }

  void _generateAttendance() {
    for (int i = 1; i <= 12; i++) {
      final firstDay = DateTime(2025, i, 1);
      final daysInMonth = DateUtils.getDaysInMonth(2025, i);
      List<Map<String, dynamic>> days = [];

      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(2025, i, d);
        final isWeekend = date.weekday == 6 || date.weekday == 7;
        final isHoliday = holidays.any((h) => h.year == date.year && h.month == date.month && h.day == date.day);

        if (isWeekend || isHoliday) {
          days.add({'date': date, 'status': null});
        } else {
          days.add({'date': date, 'status': 'X'}); // по умолчанию отсутствует
        }
      }

      monthlyAttendance[DateFormat.MMMM('ru').format(firstDay)] = days;
    }
  }

  /// Обновление посещения при сканировании QR-кода
  void markAttendance(DateTime date) {
    final monthKey = DateFormat.MMMM('ru').format(date);
    final days = monthlyAttendance[monthKey];

    if (days == null) return;

    for (var day in days) {
      if (_isSameDay(day['date'], date)) {
        day['status'] = '✓';
        break;
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
