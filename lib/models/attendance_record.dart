// lib/models/attendance_record.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

// Конвертер для Firestore Timestamp <-> DateTime
// Можно взять из grade.dart или вынести в общий файл helpers/converters.dart
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();
  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// Конвертер для Date -> Timestamp (только дата, без времени)
// Используется, если в Firestore хранится только дата YYYY-MM-DD, но в модели хотим DateTime
// class DateConverter implements JsonConverter<DateTime, String> {
//   const DateConverter();
//   @override
//   DateTime fromJson(String dateString) => DateTime.parse(dateString); // Преобразуем строку YYYY-MM-DD в DateTime
//   @override
//   String toJson(DateTime date) => "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"; // Форматируем в YYYY-MM-DD
// }

// --- Добавляем Enum для статуса посещаемости ---
enum AttendanceStatus {
  present, // Присутствовал
  absentValid, // Отсутствовал по уваж. причине
  absentInvalid, // Прогул
  late, // Опоздал
}

// Конвертер для Enum <-> String
class AttendanceStatusConverter
    implements JsonConverter<AttendanceStatus, String> {
  const AttendanceStatusConverter();

  @override
  AttendanceStatus fromJson(String json) {
    switch (json) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent_valid':
        return AttendanceStatus.absentValid;
      case 'absent_invalid':
        return AttendanceStatus.absentInvalid;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus
            .absentInvalid; // По умолчанию - прогул? Или бросать ошибку?
    }
  }

  @override
  String toJson(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absentValid:
        return 'absent_valid';
      case AttendanceStatus.absentInvalid:
        return 'absent_invalid';
      case AttendanceStatus.late:
        return 'late';
    }
  }
}
// -----------------------------------------

@freezed
class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    // ID можно не хранить, если это ID документа Firestore
    // @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String studentId,
    String? studentName, // Имя (для удобства отображения в журнале)
    required String groupId, // ID группы
    // Используем DateTime для даты, но в Firestore может храниться Timestamp или String
    @TimestampConverter()
    required DateTime date, // Дата занятия (лучше Timestamp начала дня)
    required int lessonNumber, // Номер пары/урока
    required String subject, // Предмет
    @AttendanceStatusConverter()
    required AttendanceStatus status, // Статус посещаемости
    String? reason, // Причина отсутствия (опционально)
    required String recordedByTeacherId, // ID учителя, который отметил
    @TimestampConverter()
    required DateTime timestamp, // Время создания/обновления записи
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

// Дополнительные хелперы для модели (опционально)
extension AttendanceRecordHelpers on AttendanceRecord {
  // Метод для получения иконки или цвета для статуса
  IconData get statusIcon {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline; // Присутствует
      case AttendanceStatus.absentValid:
        return Icons.help_outline; // Уваж. причина
      case AttendanceStatus.absentInvalid:
        return Icons.cancel_outlined; // Прогул
      case AttendanceStatus.late:
        return Icons.watch_later_outlined; // Опоздал
    }
  }

  Color statusColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.shade600;
      case AttendanceStatus.absentValid:
        return Colors.orange.shade700;
      case AttendanceStatus.absentInvalid:
        return colors.error;
      case AttendanceStatus.late:
        return Colors.blue.shade600;
    }
  }

  String get statusDisplay {
    switch (status) {
      case AttendanceStatus.present:
        return 'П'; // Присутств.
      case AttendanceStatus.absentValid:
        return 'У'; // Уваж.
      case AttendanceStatus.absentInvalid:
        return 'Н'; // Неуваж. (прогул)
      case AttendanceStatus.late:
        return 'О'; // Опоздал
    }
  }
}
