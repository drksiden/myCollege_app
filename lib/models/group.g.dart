// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  name: json['name'] as String,
  teacherId: json['teacherId'] as String,
  teacherName: json['teacherName'] as String?,
  specialty: json['specialty'] as String,
  course: (json['course'] as num).toInt(),
  subjects:
      (json['subjects'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'specialty': instance.specialty,
      'course': instance.course,
      'subjects': instance.subjects,
    };
