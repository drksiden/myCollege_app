// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) {
  return _AttendanceRecord.fromJson(json);
}

/// @nodoc
mixin _$AttendanceRecord {
  // ID можно не хранить, если это ID документа Firestore
  // @JsonKey(includeFromJson: false, includeToJson: false) String? id,
  String get studentId => throw _privateConstructorUsedError;
  String? get studentName =>
      throw _privateConstructorUsedError; // Имя (для удобства отображения в журнале)
  String get groupId => throw _privateConstructorUsedError; // ID группы
  // Используем DateTime для даты, но в Firestore может храниться Timestamp или String
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError; // Дата занятия (лучше Timestamp начала дня)
  int get lessonNumber =>
      throw _privateConstructorUsedError; // Номер пары/урока
  String get subject => throw _privateConstructorUsedError; // Предмет
  @AttendanceStatusConverter()
  AttendanceStatus get status => throw _privateConstructorUsedError; // Статус посещаемости
  String? get reason =>
      throw _privateConstructorUsedError; // Причина отсутствия (опционально)
  String get recordedByTeacherId =>
      throw _privateConstructorUsedError; // ID учителя, который отметил
  @TimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceRecordCopyWith<AttendanceRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceRecordCopyWith<$Res> {
  factory $AttendanceRecordCopyWith(
    AttendanceRecord value,
    $Res Function(AttendanceRecord) then,
  ) = _$AttendanceRecordCopyWithImpl<$Res, AttendanceRecord>;
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String groupId,
    @TimestampConverter() DateTime date,
    int lessonNumber,
    String subject,
    @AttendanceStatusConverter() AttendanceStatus status,
    String? reason,
    String recordedByTeacherId,
    @TimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res, $Val extends AttendanceRecord>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = null,
    Object? date = null,
    Object? lessonNumber = null,
    Object? subject = null,
    Object? status = null,
    Object? reason = freezed,
    Object? recordedByTeacherId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            studentId:
                null == studentId
                    ? _value.studentId
                    : studentId // ignore: cast_nullable_to_non_nullable
                        as String,
            studentName:
                freezed == studentName
                    ? _value.studentName
                    : studentName // ignore: cast_nullable_to_non_nullable
                        as String?,
            groupId:
                null == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            lessonNumber:
                null == lessonNumber
                    ? _value.lessonNumber
                    : lessonNumber // ignore: cast_nullable_to_non_nullable
                        as int,
            subject:
                null == subject
                    ? _value.subject
                    : subject // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as AttendanceStatus,
            reason:
                freezed == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String?,
            recordedByTeacherId:
                null == recordedByTeacherId
                    ? _value.recordedByTeacherId
                    : recordedByTeacherId // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceRecordImplCopyWith<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  factory _$$AttendanceRecordImplCopyWith(
    _$AttendanceRecordImpl value,
    $Res Function(_$AttendanceRecordImpl) then,
  ) = __$$AttendanceRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String groupId,
    @TimestampConverter() DateTime date,
    int lessonNumber,
    String subject,
    @AttendanceStatusConverter() AttendanceStatus status,
    String? reason,
    String recordedByTeacherId,
    @TimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class __$$AttendanceRecordImplCopyWithImpl<$Res>
    extends _$AttendanceRecordCopyWithImpl<$Res, _$AttendanceRecordImpl>
    implements _$$AttendanceRecordImplCopyWith<$Res> {
  __$$AttendanceRecordImplCopyWithImpl(
    _$AttendanceRecordImpl _value,
    $Res Function(_$AttendanceRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = null,
    Object? date = null,
    Object? lessonNumber = null,
    Object? subject = null,
    Object? status = null,
    Object? reason = freezed,
    Object? recordedByTeacherId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$AttendanceRecordImpl(
        studentId:
            null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                    as String,
        studentName:
            freezed == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                    as String?,
        groupId:
            null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        lessonNumber:
            null == lessonNumber
                ? _value.lessonNumber
                : lessonNumber // ignore: cast_nullable_to_non_nullable
                    as int,
        subject:
            null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as AttendanceStatus,
        reason:
            freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String?,
        recordedByTeacherId:
            null == recordedByTeacherId
                ? _value.recordedByTeacherId
                : recordedByTeacherId // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceRecordImpl implements _AttendanceRecord {
  const _$AttendanceRecordImpl({
    required this.studentId,
    this.studentName,
    required this.groupId,
    @TimestampConverter() required this.date,
    required this.lessonNumber,
    required this.subject,
    @AttendanceStatusConverter() required this.status,
    this.reason,
    required this.recordedByTeacherId,
    @TimestampConverter() required this.timestamp,
  });

  factory _$AttendanceRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceRecordImplFromJson(json);

  // ID можно не хранить, если это ID документа Firestore
  // @JsonKey(includeFromJson: false, includeToJson: false) String? id,
  @override
  final String studentId;
  @override
  final String? studentName;
  // Имя (для удобства отображения в журнале)
  @override
  final String groupId;
  // ID группы
  // Используем DateTime для даты, но в Firestore может храниться Timestamp или String
  @override
  @TimestampConverter()
  final DateTime date;
  // Дата занятия (лучше Timestamp начала дня)
  @override
  final int lessonNumber;
  // Номер пары/урока
  @override
  final String subject;
  // Предмет
  @override
  @AttendanceStatusConverter()
  final AttendanceStatus status;
  // Статус посещаемости
  @override
  final String? reason;
  // Причина отсутствия (опционально)
  @override
  final String recordedByTeacherId;
  // ID учителя, который отметил
  @override
  @TimestampConverter()
  final DateTime timestamp;

  @override
  String toString() {
    return 'AttendanceRecord(studentId: $studentId, studentName: $studentName, groupId: $groupId, date: $date, lessonNumber: $lessonNumber, subject: $subject, status: $status, reason: $reason, recordedByTeacherId: $recordedByTeacherId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceRecordImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.lessonNumber, lessonNumber) ||
                other.lessonNumber == lessonNumber) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.recordedByTeacherId, recordedByTeacherId) ||
                other.recordedByTeacherId == recordedByTeacherId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    studentName,
    groupId,
    date,
    lessonNumber,
    subject,
    status,
    reason,
    recordedByTeacherId,
    timestamp,
  );

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      __$$AttendanceRecordImplCopyWithImpl<_$AttendanceRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceRecordImplToJson(this);
  }
}

abstract class _AttendanceRecord implements AttendanceRecord {
  const factory _AttendanceRecord({
    required final String studentId,
    final String? studentName,
    required final String groupId,
    @TimestampConverter() required final DateTime date,
    required final int lessonNumber,
    required final String subject,
    @AttendanceStatusConverter() required final AttendanceStatus status,
    final String? reason,
    required final String recordedByTeacherId,
    @TimestampConverter() required final DateTime timestamp,
  }) = _$AttendanceRecordImpl;

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =
      _$AttendanceRecordImpl.fromJson;

  // ID можно не хранить, если это ID документа Firestore
  // @JsonKey(includeFromJson: false, includeToJson: false) String? id,
  @override
  String get studentId;
  @override
  String? get studentName; // Имя (для удобства отображения в журнале)
  @override
  String get groupId; // ID группы
  // Используем DateTime для даты, но в Firestore может храниться Timestamp или String
  @override
  @TimestampConverter()
  DateTime get date; // Дата занятия (лучше Timestamp начала дня)
  @override
  int get lessonNumber; // Номер пары/урока
  @override
  String get subject; // Предмет
  @override
  @AttendanceStatusConverter()
  AttendanceStatus get status; // Статус посещаемости
  @override
  String? get reason; // Причина отсутствия (опционально)
  @override
  String get recordedByTeacherId; // ID учителя, который отметил
  @override
  @TimestampConverter()
  DateTime get timestamp;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
