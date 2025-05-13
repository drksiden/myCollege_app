// lib/models/assignment.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

// Конвертер для Timestamp <-> DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();
  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// Модель для вложения (файл)
@freezed
class AssignmentAttachment with _$AssignmentAttachment {
  const factory AssignmentAttachment({
    required String fileName,
    required String fileUrl, // URL из Firebase Storage
    String? fileType, // например, 'pdf', 'docx', 'image/png'
  }) = _AssignmentAttachment;

  factory AssignmentAttachment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentAttachmentFromJson(json);
}

@freezed
class Assignment with _$Assignment {
  const factory Assignment({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id, // ID документа Firestore
    required String title,
    String? description,
    @TimestampConverter() required DateTime dueDate, // Срок сдачи
    @TimestampConverter() required DateTime createdAt,
    required String teacherId,
    String? teacherName, // Имя учителя (денормализовано)
    required List<String> groupIds, // Для каких групп это задание
    String? subject, // К какому предмету относится
    @Default([]) List<AssignmentAttachment> attachments, // Прикрепленные файлы
    int? maxPoints,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}
