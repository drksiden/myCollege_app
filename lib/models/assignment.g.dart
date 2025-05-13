// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentAttachmentImpl _$$AssignmentAttachmentImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentAttachmentImpl(
  fileName: json['fileName'] as String,
  fileUrl: json['fileUrl'] as String,
  fileType: json['fileType'] as String?,
);

Map<String, dynamic> _$$AssignmentAttachmentImplToJson(
  _$AssignmentAttachmentImpl instance,
) => <String, dynamic>{
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'fileType': instance.fileType,
};

_$AssignmentImpl _$$AssignmentImplFromJson(
  Map<String, dynamic> json,
) => _$AssignmentImpl(
  title: json['title'] as String,
  description: json['description'] as String?,
  dueDate: const TimestampConverter().fromJson(json['dueDate'] as Timestamp),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  teacherId: json['teacherId'] as String,
  teacherName: json['teacherName'] as String?,
  groupIds:
      (json['groupIds'] as List<dynamic>).map((e) => e as String).toList(),
  subject: json['subject'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => AssignmentAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  maxPoints: (json['maxPoints'] as num?)?.toInt(),
);

Map<String, dynamic> _$$AssignmentImplToJson(_$AssignmentImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'dueDate': const TimestampConverter().toJson(instance.dueDate),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'groupIds': instance.groupIds,
      'subject': instance.subject,
      'attachments': instance.attachments,
      'maxPoints': instance.maxPoints,
    };
