// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleEntry _$ScheduleEntryFromJson(Map<String, dynamic> json) =>
    ScheduleEntry(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      teacherId: json['teacherId'] as String,
      groupId: json['groupId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      room: json['room'] as String,
      type: json['type'] as String,
      duration: (json['duration'] as num).toInt(),
      weekType: json['weekType'] as String,
      isFloating: json['isFloating'] as bool,
      semester: (json['semester'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$ScheduleEntryToJson(ScheduleEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'teacherId': instance.teacherId,
      'groupId': instance.groupId,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'room': instance.room,
      'type': instance.type,
      'duration': instance.duration,
      'weekType': instance.weekType,
      'isFloating': instance.isFloating,
      'semester': instance.semester,
      'year': instance.year,
    };
