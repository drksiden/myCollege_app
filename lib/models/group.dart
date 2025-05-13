// lib/models/group.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'group.freezed.dart';
part 'group.g.dart';

// Конвертер для Timestamp <-> DateTime (если понадобится)
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();
  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();
  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class Group with _$Group {
  const factory Group({
    // Применяем аннотацию к параметру конструктора.
    // Freezed должен корректно обработать это для генерируемого поля.
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String name, // Название группы (П4А)
    required String teacherId, // UID куратора/преподавателя группы
    String? teacherName, // Имя куратора (для отображения)
    required String specialty, // Специальность
    required int course, // Курс
    // Список предметов (важно для фильтра в журнале)
    required List<String> subjects,
    // Используем TimestampConverter, если поля createdAt/updatedAt есть
    // @TimestampConverter() DateTime? createdAt,
    // @TimestampConverter() DateTime? updatedAt,
  }) = _Group;

  // fromJson остается без изменений
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
