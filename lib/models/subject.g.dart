// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectImpl _$$SubjectImplFromJson(Map<String, dynamic> json) =>
    _$SubjectImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      credits: (json['credits'] as num).toInt(),
      hours: (json['hours'] as num).toInt(),
      hoursPerSemester: (json['hoursPerSemester'] as num).toInt(),
      hoursPerWeek: (json['hoursPerWeek'] as num).toInt(),
      teacherId: json['teacherId'] as String,
      type: json['type'] as String,
      groups:
          (json['groups'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: _timestampFromJson(json['createdAt']),
      updatedAt: _timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$SubjectImplToJson(_$SubjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'credits': instance.credits,
      'hours': instance.hours,
      'hoursPerSemester': instance.hoursPerSemester,
      'hoursPerWeek': instance.hoursPerWeek,
      'teacherId': instance.teacherId,
      'type': instance.type,
      'groups': instance.groups,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
    };
