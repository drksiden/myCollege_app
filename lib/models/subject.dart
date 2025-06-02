import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
class Subject with _$Subject {
  const factory Subject({
    required String id,
    required String name,
    String? description,
    String? department,
    @Default(false) bool isActive,
    required int credits,
    required int hours,
    required int hoursPerSemester,
    required int hoursPerWeek,
    required String teacherId,
    required String type,
    required List<String> groups,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
}

// Конвертеры для DateTime
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.parse(value as String);
}

dynamic _timestampToJson(DateTime date) => date.toIso8601String();
