// lib/models/schedule_entry.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'schedule_entry.freezed.dart';
part 'schedule_entry.g.dart';

@freezed
@JsonSerializable()
class ScheduleEntry with _$ScheduleEntry {
  const factory ScheduleEntry({
    required String id,
    required String subjectId,
    required String teacherId,
    required String groupId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
    required String type,
    required int duration,
    required String weekType,
    required bool isFloating,
    required int semester,
    required int year,
  }) = _ScheduleEntry;

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      json['id'] =
          '${json['dayOfWeek']}_${json['startTime']}_${json['subjectId']}';
    }
    return _$ScheduleEntryFromJson(json);
  }

  // Пустой приватный конструктор для freezed
  const ScheduleEntry._();

  // --- Вспомогательные геттеры ---

  // Парсинг времени начала (может вернуть null при ошибке формата)
  TimeOfDay? get startTimeOfDay {
    try {
      final parts = startTime.split(':');
      if (parts.length != 2) return null;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
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
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  // Проверка, идет ли эта пара прямо сейчас
  bool isCurrentLesson() {
    final now = DateTime.now();
    final currentDay = now.weekday;
    if (currentDay != dayOfWeek) return false;

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 &&
        currentTime.compareTo(endTime) <= 0;
  }

  // Получение названия дня недели
  String get dayName {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return '??';
  }
}

// Конвертеры для DateTime
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.parse(value as String);
}

dynamic _timestampToJson(DateTime date) => date.toIso8601String();
