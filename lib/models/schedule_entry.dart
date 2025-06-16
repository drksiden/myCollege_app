// lib/models/schedule_entry.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'schedule_entry.freezed.dart';
part 'schedule_entry.g.dart';

// Конвертер для работы с датами из Firestore
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

@freezed
class ScheduleEntry with _$ScheduleEntry {
  const factory ScheduleEntry({
    // Обязательные поля
    required String id,
    required String groupId,
    required String semesterId,
    required String subjectId,
    required String teacherId,
    required String startTime,
    required String endTime,

    // Поля с значениями по умолчанию
    @Default(1) int dayOfWeek,
    @Default('lecture') String type,
    @Default('all') String weekType,
    @Default('') String room,
    @Default(90) int duration,
    @Default(false) bool isFloating,

    // Поля с датами (могут быть null)
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ScheduleEntry;

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    print('DEBUG: ScheduleEntry.fromJson: $json');

    try {
      final entry = ScheduleEntry(
        id: _safeString(json['id']),
        groupId: _safeString(json['groupId']),
        semesterId: _safeString(json['semesterId']),
        subjectId: _safeString(json['subjectId']),
        teacherId: _safeString(json['teacherId']),
        startTime: _safeString(json['startTime']),
        endTime: _safeString(json['endTime']),
        dayOfWeek: _safeInt(json['dayOfWeek'], 1),
        type: json['type']?.toString() ?? 'lecture',
        weekType: json['weekType']?.toString() ?? 'all',
        room: json['room']?.toString() ?? '',
        duration: _safeInt(json['duration'], 90),
        isFloating: json['isFloating'] ?? false,
        createdAt: _parseTimestamp(json['createdAt']),
        updatedAt: _parseTimestamp(json['updatedAt']),
      );

      print('DEBUG: Created ScheduleEntry: ${entry.toString()}');
      return entry;
    } catch (e, stackTrace) {
      print('DEBUG: Error creating ScheduleEntry from JSON: $e');
      print('DEBUG: Stack trace: $stackTrace');
      print('DEBUG: JSON data: $json');
      rethrow;
    }
  }

  // Дополнительные методы
  const ScheduleEntry._();

  // Безопасное преобразование в int
  static int _safeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Безопасное преобразование в String
  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    throw Exception('Invalid format for string conversion');
  }

  // Безопасное преобразование Timestamp
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    throw Exception('Invalid format for timestamp conversion');
  }
}

// Расширения для удобной работы с расписанием
extension ScheduleEntryExtensions on ScheduleEntry {
  // Парсинг времени начала
  TimeOfDay? get startTimeOfDay {
    try {
      final parts = startTime.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  // Парсинг времени конца
  TimeOfDay? get endTimeOfDay {
    try {
      final parts = endTime.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  // Проверка, идет ли занятие сейчас
  bool isCurrentLesson() {
    final now = DateTime.now();
    final currentDay = now.weekday;
    if (currentDay != dayOfWeek) return false;

    final start = startTimeOfDay;
    final end = endTimeOfDay;
    if (start == null || end == null) return false;

    final nowTime = TimeOfDay.fromDateTime(now);
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  // Получение названия дня недели
  String get dayName {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return '??';
  }

  // Получение полного названия дня
  String get fullDayName {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return 'Неизвестный день';
  }

  // Получение иконки типа занятия
  IconData get typeIcon {
    switch (type) {
      case 'lecture':
        return Icons.school;
      case 'practice':
        return Icons.groups;
      case 'lab':
        return Icons.computer;
      case 'seminar':
        return Icons.forum;
      default:
        return Icons.class_;
    }
  }

  // Получение названия типа занятия
  String get typeName {
    switch (type) {
      case 'lecture':
        return 'Лекция';
      case 'practice':
        return 'Практика';
      case 'lab':
        return 'Лабораторная';
      case 'seminar':
        return 'Семинар';
      default:
        return type;
    }
  }

  // Проверка валидности
  bool get isValid {
    final isBasicValid =
        id.isNotEmpty &&
        groupId.isNotEmpty &&
        subjectId.isNotEmpty &&
        teacherId.isNotEmpty &&
        startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        dayOfWeek >= 1 &&
        dayOfWeek <= 7;

    if (!isBasicValid) {
      print('DEBUG: ScheduleEntry validation failed - basic fields');
      print('DEBUG: id: "$id", groupId: "$groupId", subjectId: "$subjectId"');
      print(
        'DEBUG: teacherId: "$teacherId", startTime: "$startTime", endTime: "$endTime"',
      );
      print('DEBUG: dayOfWeek: $dayOfWeek');
      return false;
    }

    final start = startTimeOfDay;
    final end = endTimeOfDay;

    if (start == null || end == null) {
      print('DEBUG: ScheduleEntry validation failed - time format');
      print('DEBUG: startTime: "$startTime", endTime: "$endTime"');
      return false;
    }

    // Проверка, что время окончания позже времени начала
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (endMinutes <= startMinutes) {
      print(
        'DEBUG: ScheduleEntry validation failed - end time before start time',
      );
      print('DEBUG: startTime: "$startTime", endTime: "$endTime"');
      return false;
    }

    return true;
  }

  bool isCurrentWeek() {
    if (weekType == 'all') return true;

    // Определение четности недели относительно начала учебного года
    final now = DateTime.now();
    final academicYearStart = DateTime(now.year, 9, 1); // Начало учебного года

    // Если текущая дата до начала учебного года, используем предыдущий год
    final startDate =
        now.isBefore(academicYearStart)
            ? DateTime(now.year - 1, 9, 1)
            : academicYearStart;

    final weekNumber = now.difference(startDate).inDays ~/ 7 + 1;
    final isEvenWeek = weekNumber % 2 == 0;

    if (weekType == 'numerator') return !isEvenWeek;
    if (weekType == 'denominator') return isEvenWeek;

    return true;
  }
}
