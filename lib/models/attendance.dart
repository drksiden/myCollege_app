import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

// Конвертер для Firestore Timestamp <-> DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class Attendance with _$Attendance {
  const factory Attendance({
    required String studentId,
    String? studentName,
    String? groupId,
    required String subject,
    @TimestampConverter() required DateTime date,
    required AttendanceStatus status,
    String? comment,
    String? teacherId,
    String? teacherName,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}

// Статус посещаемости
enum AttendanceStatus {
  present, // Присутствовал
  absent, // Отсутствовал
  late, // Опоздал
  excused, // Уважительная причина
}

// Расширение для получения цвета статуса
extension AttendanceStatusColor on AttendanceStatus {
  Color getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  String getDisplayName() {
    switch (this) {
      case AttendanceStatus.present:
        return 'Присутствовал';
      case AttendanceStatus.absent:
        return 'Отсутствовал';
      case AttendanceStatus.late:
        return 'Опоздал';
      case AttendanceStatus.excused:
        return 'Уважительная причина';
    }
  }

  IconData getIcon() {
    switch (this) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.info_outline;
    }
  }
}
