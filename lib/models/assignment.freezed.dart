// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignmentAttachment _$AssignmentAttachmentFromJson(Map<String, dynamic> json) {
  return _AssignmentAttachment.fromJson(json);
}

/// @nodoc
mixin _$AssignmentAttachment {
  String get fileName => throw _privateConstructorUsedError;
  String get fileUrl =>
      throw _privateConstructorUsedError; // URL из Firebase Storage
  String? get fileType => throw _privateConstructorUsedError;

  /// Serializes this AssignmentAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentAttachmentCopyWith<AssignmentAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentAttachmentCopyWith<$Res> {
  factory $AssignmentAttachmentCopyWith(
    AssignmentAttachment value,
    $Res Function(AssignmentAttachment) then,
  ) = _$AssignmentAttachmentCopyWithImpl<$Res, AssignmentAttachment>;
  @useResult
  $Res call({String fileName, String fileUrl, String? fileType});
}

/// @nodoc
class _$AssignmentAttachmentCopyWithImpl<
  $Res,
  $Val extends AssignmentAttachment
>
    implements $AssignmentAttachmentCopyWith<$Res> {
  _$AssignmentAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileUrl = null,
    Object? fileType = freezed,
  }) {
    return _then(
      _value.copyWith(
            fileName:
                null == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
                        as String,
            fileUrl:
                null == fileUrl
                    ? _value.fileUrl
                    : fileUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            fileType:
                freezed == fileType
                    ? _value.fileType
                    : fileType // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentAttachmentImplCopyWith<$Res>
    implements $AssignmentAttachmentCopyWith<$Res> {
  factory _$$AssignmentAttachmentImplCopyWith(
    _$AssignmentAttachmentImpl value,
    $Res Function(_$AssignmentAttachmentImpl) then,
  ) = __$$AssignmentAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fileName, String fileUrl, String? fileType});
}

/// @nodoc
class __$$AssignmentAttachmentImplCopyWithImpl<$Res>
    extends _$AssignmentAttachmentCopyWithImpl<$Res, _$AssignmentAttachmentImpl>
    implements _$$AssignmentAttachmentImplCopyWith<$Res> {
  __$$AssignmentAttachmentImplCopyWithImpl(
    _$AssignmentAttachmentImpl _value,
    $Res Function(_$AssignmentAttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignmentAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileUrl = null,
    Object? fileType = freezed,
  }) {
    return _then(
      _$AssignmentAttachmentImpl(
        fileName:
            null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                    as String,
        fileUrl:
            null == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        fileType:
            freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentAttachmentImpl implements _AssignmentAttachment {
  const _$AssignmentAttachmentImpl({
    required this.fileName,
    required this.fileUrl,
    this.fileType,
  });

  factory _$AssignmentAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentAttachmentImplFromJson(json);

  @override
  final String fileName;
  @override
  final String fileUrl;
  // URL из Firebase Storage
  @override
  final String? fileType;

  @override
  String toString() {
    return 'AssignmentAttachment(fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentAttachmentImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fileName, fileUrl, fileType);

  /// Create a copy of AssignmentAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentAttachmentImplCopyWith<_$AssignmentAttachmentImpl>
  get copyWith =>
      __$$AssignmentAttachmentImplCopyWithImpl<_$AssignmentAttachmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentAttachmentImplToJson(this);
  }
}

abstract class _AssignmentAttachment implements AssignmentAttachment {
  const factory _AssignmentAttachment({
    required final String fileName,
    required final String fileUrl,
    final String? fileType,
  }) = _$AssignmentAttachmentImpl;

  factory _AssignmentAttachment.fromJson(Map<String, dynamic> json) =
      _$AssignmentAttachmentImpl.fromJson;

  @override
  String get fileName;
  @override
  String get fileUrl; // URL из Firebase Storage
  @override
  String? get fileType;

  /// Create a copy of AssignmentAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentAttachmentImplCopyWith<_$AssignmentAttachmentImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Assignment _$AssignmentFromJson(Map<String, dynamic> json) {
  return _Assignment.fromJson(json);
}

/// @nodoc
mixin _$Assignment {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id => throw _privateConstructorUsedError; // ID документа Firestore
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get dueDate => throw _privateConstructorUsedError; // Срок сдачи
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String? get teacherName =>
      throw _privateConstructorUsedError; // Имя учителя (денормализовано)
  List<String> get groupIds =>
      throw _privateConstructorUsedError; // Для каких групп это задание
  String? get subject =>
      throw _privateConstructorUsedError; // К какому предмету относится
  List<AssignmentAttachment> get attachments =>
      throw _privateConstructorUsedError; // Прикрепленные файлы
  int? get maxPoints => throw _privateConstructorUsedError;

  /// Serializes this Assignment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentCopyWith<Assignment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentCopyWith<$Res> {
  factory $AssignmentCopyWith(
    Assignment value,
    $Res Function(Assignment) then,
  ) = _$AssignmentCopyWithImpl<$Res, Assignment>;
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String title,
    String? description,
    @TimestampConverter() DateTime dueDate,
    @TimestampConverter() DateTime createdAt,
    String teacherId,
    String? teacherName,
    List<String> groupIds,
    String? subject,
    List<AssignmentAttachment> attachments,
    int? maxPoints,
  });
}

/// @nodoc
class _$AssignmentCopyWithImpl<$Res, $Val extends Assignment>
    implements $AssignmentCopyWith<$Res> {
  _$AssignmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? dueDate = null,
    Object? createdAt = null,
    Object? teacherId = null,
    Object? teacherName = freezed,
    Object? groupIds = null,
    Object? subject = freezed,
    Object? attachments = null,
    Object? maxPoints = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            dueDate:
                null == dueDate
                    ? _value.dueDate
                    : dueDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            teacherId:
                null == teacherId
                    ? _value.teacherId
                    : teacherId // ignore: cast_nullable_to_non_nullable
                        as String,
            teacherName:
                freezed == teacherName
                    ? _value.teacherName
                    : teacherName // ignore: cast_nullable_to_non_nullable
                        as String?,
            groupIds:
                null == groupIds
                    ? _value.groupIds
                    : groupIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            subject:
                freezed == subject
                    ? _value.subject
                    : subject // ignore: cast_nullable_to_non_nullable
                        as String?,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
                        as List<AssignmentAttachment>,
            maxPoints:
                freezed == maxPoints
                    ? _value.maxPoints
                    : maxPoints // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentImplCopyWith<$Res>
    implements $AssignmentCopyWith<$Res> {
  factory _$$AssignmentImplCopyWith(
    _$AssignmentImpl value,
    $Res Function(_$AssignmentImpl) then,
  ) = __$$AssignmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String title,
    String? description,
    @TimestampConverter() DateTime dueDate,
    @TimestampConverter() DateTime createdAt,
    String teacherId,
    String? teacherName,
    List<String> groupIds,
    String? subject,
    List<AssignmentAttachment> attachments,
    int? maxPoints,
  });
}

/// @nodoc
class __$$AssignmentImplCopyWithImpl<$Res>
    extends _$AssignmentCopyWithImpl<$Res, _$AssignmentImpl>
    implements _$$AssignmentImplCopyWith<$Res> {
  __$$AssignmentImplCopyWithImpl(
    _$AssignmentImpl _value,
    $Res Function(_$AssignmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? dueDate = null,
    Object? createdAt = null,
    Object? teacherId = null,
    Object? teacherName = freezed,
    Object? groupIds = null,
    Object? subject = freezed,
    Object? attachments = null,
    Object? maxPoints = freezed,
  }) {
    return _then(
      _$AssignmentImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        dueDate:
            null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        teacherId:
            null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                    as String,
        teacherName:
            freezed == teacherName
                ? _value.teacherName
                : teacherName // ignore: cast_nullable_to_non_nullable
                    as String?,
        groupIds:
            null == groupIds
                ? _value._groupIds
                : groupIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        subject:
            freezed == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                    as String?,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                    as List<AssignmentAttachment>,
        maxPoints:
            freezed == maxPoints
                ? _value.maxPoints
                : maxPoints // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentImpl implements _Assignment {
  const _$AssignmentImpl({
    @JsonKey(includeFromJson: false, includeToJson: false) this.id,
    required this.title,
    this.description,
    @TimestampConverter() required this.dueDate,
    @TimestampConverter() required this.createdAt,
    required this.teacherId,
    this.teacherName,
    required final List<String> groupIds,
    this.subject,
    final List<AssignmentAttachment> attachments = const [],
    this.maxPoints,
  }) : _groupIds = groupIds,
       _attachments = attachments;

  factory _$AssignmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentImplFromJson(json);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  // ID документа Firestore
  @override
  final String title;
  @override
  final String? description;
  @override
  @TimestampConverter()
  final DateTime dueDate;
  // Срок сдачи
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final String teacherId;
  @override
  final String? teacherName;
  // Имя учителя (денормализовано)
  final List<String> _groupIds;
  // Имя учителя (денормализовано)
  @override
  List<String> get groupIds {
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupIds);
  }

  // Для каких групп это задание
  @override
  final String? subject;
  // К какому предмету относится
  final List<AssignmentAttachment> _attachments;
  // К какому предмету относится
  @override
  @JsonKey()
  List<AssignmentAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  // Прикрепленные файлы
  @override
  final int? maxPoints;

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, description: $description, dueDate: $dueDate, createdAt: $createdAt, teacherId: $teacherId, teacherName: $teacherName, groupIds: $groupIds, subject: $subject, attachments: $attachments, maxPoints: $maxPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.maxPoints, maxPoints) ||
                other.maxPoints == maxPoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    dueDate,
    createdAt,
    teacherId,
    teacherName,
    const DeepCollectionEquality().hash(_groupIds),
    subject,
    const DeepCollectionEquality().hash(_attachments),
    maxPoints,
  );

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentImplCopyWith<_$AssignmentImpl> get copyWith =>
      __$$AssignmentImplCopyWithImpl<_$AssignmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentImplToJson(this);
  }
}

abstract class _Assignment implements Assignment {
  const factory _Assignment({
    @JsonKey(includeFromJson: false, includeToJson: false) final String? id,
    required final String title,
    final String? description,
    @TimestampConverter() required final DateTime dueDate,
    @TimestampConverter() required final DateTime createdAt,
    required final String teacherId,
    final String? teacherName,
    required final List<String> groupIds,
    final String? subject,
    final List<AssignmentAttachment> attachments,
    final int? maxPoints,
  }) = _$AssignmentImpl;

  factory _Assignment.fromJson(Map<String, dynamic> json) =
      _$AssignmentImpl.fromJson;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id; // ID документа Firestore
  @override
  String get title;
  @override
  String? get description;
  @override
  @TimestampConverter()
  DateTime get dueDate; // Срок сдачи
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String get teacherId;
  @override
  String? get teacherName; // Имя учителя (денормализовано)
  @override
  List<String> get groupIds; // Для каких групп это задание
  @override
  String? get subject; // К какому предмету относится
  @override
  List<AssignmentAttachment> get attachments; // Прикрепленные файлы
  @override
  int? get maxPoints;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentImplCopyWith<_$AssignmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
