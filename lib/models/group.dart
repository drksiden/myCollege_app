import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'group.freezed.dart';
part 'group.g.dart';

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
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String specialization, // Специализация
    required int year, // Курс
    String? description,
    String? curatorId, // ID куратора
    String? curatorName, // Имя куратора
    List<String>? studentIds, // Список ID студентов
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
