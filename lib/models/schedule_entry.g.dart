// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleEntryImpl _$$ScheduleEntryImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleEntryImpl(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      lessonNumber: (json['lessonNumber'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      subject: json['subject'] as String,
      teacherId: json['teacherId'] as String?,
      teacherName: json['teacherName'] as String?,
      classroom: json['classroom'] as String?,
      lessonType: json['lessonType'] as String?,
    );

Map<String, dynamic> _$$ScheduleEntryImplToJson(_$ScheduleEntryImpl instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'lessonNumber': instance.lessonNumber,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'subject': instance.subject,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'classroom': instance.classroom,
      'lessonType': instance.lessonType,
    };
