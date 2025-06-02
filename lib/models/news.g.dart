// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsImpl _$$NewsImplFromJson(Map<String, dynamic> json) => _$NewsImpl(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
  updatedAt: _nullableDateTimeFromTimestamp(json['updatedAt'] as Timestamp?),
  isPublished: json['isPublished'] as bool?,
  publishedAt: _nullableDateTimeFromTimestamp(
    json['publishedAt'] as Timestamp?,
  ),
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$NewsImplToJson(_$NewsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'title': instance.title,
      'content': instance.content,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _nullableDateTimeToTimestamp(instance.updatedAt),
      'isPublished': instance.isPublished,
      'publishedAt': _nullableDateTimeToTimestamp(instance.publishedAt),
      'images': instance.images,
      'tags': instance.tags,
    };
