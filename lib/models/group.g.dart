// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  specialization: json['specialization'] as String,
  year: (json['year'] as num).toInt(),
  description: json['description'] as String?,
  curatorId: json['curatorId'] as String?,
  curatorName: json['curatorName'] as String?,
  studentIds:
      (json['studentIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['createdAt'],
    const TimestampConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['updatedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialization': instance.specialization,
      'year': instance.year,
      'description': instance.description,
      'curatorId': instance.curatorId,
      'curatorName': instance.curatorName,
      'studentIds': instance.studentIds,
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
