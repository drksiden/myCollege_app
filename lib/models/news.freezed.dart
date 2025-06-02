// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

News _$NewsFromJson(Map<String, dynamic> json) {
  return _News.fromJson(json);
}

/// @nodoc
mixin _$News {
  String get id => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // Используем конвертеры для обязательного поля
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get createdAt => throw _privateConstructorUsedError; // Используем конвертеры для НЕобязательных (nullable) полей
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool? get isPublished =>
      throw _privateConstructorUsedError; // Используем конвертеры для НЕобязательных (nullable) полей
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this News to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of News
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsCopyWith<News> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsCopyWith<$Res> {
  factory $NewsCopyWith(News value, $Res Function(News) then) =
      _$NewsCopyWithImpl<$Res, News>;
  @useResult
  $Res call({
    String id,
    String authorId,
    String title,
    String content,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime createdAt,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? updatedAt,
    bool? isPublished,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? publishedAt,
    List<String>? images,
    List<String>? tags,
  });
}

/// @nodoc
class _$NewsCopyWithImpl<$Res, $Val extends News>
    implements $NewsCopyWith<$Res> {
  _$NewsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of News
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPublished = freezed,
    Object? publishedAt = freezed,
    Object? images = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            authorId:
                null == authorId
                    ? _value.authorId
                    : authorId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isPublished:
                freezed == isPublished
                    ? _value.isPublished
                    : isPublished // ignore: cast_nullable_to_non_nullable
                        as bool?,
            publishedAt:
                freezed == publishedAt
                    ? _value.publishedAt
                    : publishedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            images:
                freezed == images
                    ? _value.images
                    : images // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            tags:
                freezed == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NewsImplCopyWith<$Res> implements $NewsCopyWith<$Res> {
  factory _$$NewsImplCopyWith(
    _$NewsImpl value,
    $Res Function(_$NewsImpl) then,
  ) = __$$NewsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorId,
    String title,
    String content,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime createdAt,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? updatedAt,
    bool? isPublished,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? publishedAt,
    List<String>? images,
    List<String>? tags,
  });
}

/// @nodoc
class __$$NewsImplCopyWithImpl<$Res>
    extends _$NewsCopyWithImpl<$Res, _$NewsImpl>
    implements _$$NewsImplCopyWith<$Res> {
  __$$NewsImplCopyWithImpl(_$NewsImpl _value, $Res Function(_$NewsImpl) _then)
    : super(_value, _then);

  /// Create a copy of News
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isPublished = freezed,
    Object? publishedAt = freezed,
    Object? images = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _$NewsImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        authorId:
            null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isPublished:
            freezed == isPublished
                ? _value.isPublished
                : isPublished // ignore: cast_nullable_to_non_nullable
                    as bool?,
        publishedAt:
            freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        images:
            freezed == images
                ? _value._images
                : images // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        tags:
            freezed == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsImpl implements _News {
  const _$NewsImpl({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.createdAt,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    this.updatedAt,
    this.isPublished,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    this.publishedAt,
    final List<String>? images,
    final List<String>? tags,
  }) : _images = images,
       _tags = tags;

  factory _$NewsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsImplFromJson(json);

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String title;
  @override
  final String content;
  // Используем конвертеры для обязательного поля
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  // Используем конвертеры для НЕобязательных (nullable) полей
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  final DateTime? updatedAt;
  @override
  final bool? isPublished;
  // Используем конвертеры для НЕобязательных (nullable) полей
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  final DateTime? publishedAt;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'News(id: $id, authorId: $authorId, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, isPublished: $isPublished, publishedAt: $publishedAt, images: $images, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    title,
    content,
    createdAt,
    updatedAt,
    isPublished,
    publishedAt,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of News
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsImplCopyWith<_$NewsImpl> get copyWith =>
      __$$NewsImplCopyWithImpl<_$NewsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsImplToJson(this);
  }
}

abstract class _News implements News {
  const factory _News({
    required final String id,
    required final String authorId,
    required final String title,
    required final String content,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime createdAt,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    final DateTime? updatedAt,
    final bool? isPublished,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    final DateTime? publishedAt,
    final List<String>? images,
    final List<String>? tags,
  }) = _$NewsImpl;

  factory _News.fromJson(Map<String, dynamic> json) = _$NewsImpl.fromJson;

  @override
  String get id;
  @override
  String get authorId;
  @override
  String get title;
  @override
  String get content; // Используем конвертеры для обязательного поля
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get createdAt; // Используем конвертеры для НЕобязательных (nullable) полей
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get updatedAt;
  @override
  bool? get isPublished; // Используем конвертеры для НЕобязательных (nullable) полей
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get publishedAt;
  @override
  List<String>? get images;
  @override
  List<String>? get tags;

  /// Create a copy of News
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsImplCopyWith<_$NewsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
