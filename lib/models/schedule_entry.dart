// lib/models/schedule_entry.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart'; // Для TimeOfDay
// import 'package:cloud_firestore/cloud_firestore.dart'; // Если будешь использовать Timestamp

part 'schedule_entry.freezed.dart';
part 'schedule_entry.g.dart';

@freezed
class ScheduleEntry with _$ScheduleEntry {
  const factory ScheduleEntry({
    String? id, // ID документа в Firestore
    required int dayOfWeek, // 1=Пн, 2=Вт, ..., 7=Вс
    required int lessonNumber, // Номер пары/урока
    required String startTime, // Время начала (HH:mm)
    required String endTime, // Время конца (HH:mm)
    required String subject, // Название предмета
    String? teacherId, // ID преподавателя
    String? teacherName, // Имя преподавателя
    String? classroom, // Аудитория
    String? lessonType, // Тип занятия ("Лекция", "Практика", и т.д.)
    String? groupId,
    // Timestamp? date, // Для конкретной даты (если нужно переопределить день недели)
    // String? weekType, // Четная/нечетная неделя
    // bool? isRecurring,2q

    // Не будем добавлять @JsonKey(ignore: true) TimeOfDay,
    // т.к. парсинг лучше делать при отображении
  }) = _ScheduleEntry;

  // Конструктор из JSON для Firestore
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntryFromJson(json);

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
    final start = startTimeOfDay;
    final end = endTimeOfDay;
    if (start == null || end == null) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    // Конец пары - не включаем саму минуту конца (например, пара до 10:00 идет до 09:59:59)
    final endMinutes = end.hour * 60 + end.minute;

    // Проверка дня недели
    final currentDayOfWeek = DateTime.now().weekday; // 1=Пн, ..., 7=Вс
    if (currentDayOfWeek != dayOfWeek) return false;

    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
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
