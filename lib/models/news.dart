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
    // Используем конвертеры для обязательного поля
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    // Используем конвертеры для НЕобязательных (nullable) полей
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? updatedAt,
    bool? isPublished,
    // Используем конвертеры для НЕобязательных (nullable) полей
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? publishedAt,
    List<String>? images,
    List<String>? tags,
  }) = _News;

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
}

// --- Конвертеры для ОБЯЗАТЕЛЬНЫХ полей DateTime ---

/// Преобразует Timestamp из Firestore в DateTime.
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();

/// Преобразует DateTime в Timestamp для Firestore.
Timestamp _dateTimeToTimestamp(DateTime dateTime) =>
    Timestamp.fromDate(dateTime);

// --- Конвертеры для НЕОБЯЗАТЕЛЬНЫХ (nullable) полей DateTime? ---

/// Преобразует Timestamp из Firestore в DateTime?, обрабатывая null.
DateTime? _nullableDateTimeFromTimestamp(Timestamp? timestamp) =>
    timestamp?.toDate();

/// Преобразует DateTime? в Timestamp для Firestore, обрабатывая null.
Timestamp? _nullableDateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);
