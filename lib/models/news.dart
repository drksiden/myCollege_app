import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'news.freezed.dart';
part 'news.g.dart';

@freezed
class News with _$News {
  const factory News({
    required String id,
    required String authorId,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    DateTime? publishedAt,
    List<String>? images,
    List<String>? tags,
  }) = _News;

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: _parseTimestamp(json['createdAt'])!,
      updatedAt: _parseTimestamp(json['updatedAt']),
      isPublished: json['isPublished'] as bool?,
      publishedAt: _parseTimestamp(json['publishedAt']),
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
