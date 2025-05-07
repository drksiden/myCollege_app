// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GradeImpl _$$GradeImplFromJson(Map<String, dynamic> json) => _$GradeImpl(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String?,
  groupId: json['groupId'] as String?,
  subject: json['subject'] as String,
  grade: json['grade'] as String,
  gradeType: json['gradeType'] as String?,
  comment: json['comment'] as String?,
  date: const TimestampConverter().fromJson(json['date'] as Timestamp),
  teacherId: json['teacherId'] as String?,
  teacherName: json['teacherName'] as String?,
);

Map<String, dynamic> _$$GradeImplToJson(_$GradeImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'groupId': instance.groupId,
      'subject': instance.subject,
      'grade': instance.grade,
      'gradeType': instance.gradeType,
      'comment': instance.comment,
      'date': const TimestampConverter().toJson(instance.date),
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
    };
