// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceImpl _$$AttendanceImplFromJson(Map<String, dynamic> json) =>
    _$AttendanceImpl(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String?,
      groupId: json['groupId'] as String?,
      subject: json['subject'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      comment: json['comment'] as String?,
      teacherId: json['teacherId'] as String?,
      teacherName: json['teacherName'] as String?,
    );

Map<String, dynamic> _$$AttendanceImplToJson(_$AttendanceImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'groupId': instance.groupId,
      'subject': instance.subject,
      'date': const TimestampConverter().toJson(instance.date),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'comment': instance.comment,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
  AttendanceStatus.excused: 'excused',
};
