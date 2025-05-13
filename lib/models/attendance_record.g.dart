// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRecordImpl _$$AttendanceRecordImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceRecordImpl(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String?,
  groupId: json['groupId'] as String,
  date: const TimestampConverter().fromJson(json['date'] as Timestamp),
  lessonNumber: (json['lessonNumber'] as num).toInt(),
  subject: json['subject'] as String,
  status: const AttendanceStatusConverter().fromJson(json['status'] as String),
  reason: json['reason'] as String?,
  recordedByTeacherId: json['recordedByTeacherId'] as String,
  timestamp: const TimestampConverter().fromJson(
    json['timestamp'] as Timestamp,
  ),
);

Map<String, dynamic> _$$AttendanceRecordImplToJson(
  _$AttendanceRecordImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'groupId': instance.groupId,
  'date': const TimestampConverter().toJson(instance.date),
  'lessonNumber': instance.lessonNumber,
  'subject': instance.subject,
  'status': const AttendanceStatusConverter().toJson(instance.status),
  'reason': instance.reason,
  'recordedByTeacherId': instance.recordedByTeacherId,
  'timestamp': const TimestampConverter().toJson(instance.timestamp),
};
