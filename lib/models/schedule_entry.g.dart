// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleEntryImpl _$$ScheduleEntryImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleEntryImpl(
      id: json['id'] as String,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
      endTime: json['endTime'] as String,
      groupId: json['groupId'] as String,
      room: json['room'] as String,
      semesterId: json['semesterId'] as String,
      startTime: json['startTime'] as String,
      subjectId: json['subjectId'] as String,
      teacherId: json['teacherId'] as String,
      type: json['type'] as String? ?? 'lecture',
      weekType: json['weekType'] as String? ?? 'all',
      duration: (json['duration'] as num?)?.toInt() ?? 90,
      isFloating: json['isFloating'] as bool? ?? false,
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['createdAt'],
        const TimestampConverter().fromJson,
      ),
      updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['updatedAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$$ScheduleEntryImplToJson(_$ScheduleEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayOfWeek': instance.dayOfWeek,
      'endTime': instance.endTime,
      'groupId': instance.groupId,
      'room': instance.room,
      'semesterId': instance.semesterId,
      'startTime': instance.startTime,
      'subjectId': instance.subjectId,
      'teacherId': instance.teacherId,
      'type': instance.type,
      'weekType': instance.weekType,
      'duration': instance.duration,
      'isFloating': instance.isFloating,
      'createdAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.createdAt,
        const TimestampConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.updatedAt,
        const TimestampConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
