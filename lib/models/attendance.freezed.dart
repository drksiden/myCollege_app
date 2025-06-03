// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Attendance _$AttendanceFromJson(Map<String, dynamic> json) {
  return _Attendance.fromJson(json);
}

/// @nodoc
mixin _$Attendance {
  String get studentId => throw _privateConstructorUsedError;
  String? get studentName => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  AttendanceStatus get status => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  String? get teacherId => throw _privateConstructorUsedError;
  String? get teacherName => throw _privateConstructorUsedError;

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceCopyWith<Attendance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceCopyWith<$Res> {
  factory $AttendanceCopyWith(
    Attendance value,
    $Res Function(Attendance) then,
  ) = _$AttendanceCopyWithImpl<$Res, Attendance>;
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String? groupId,
    String subject,
    @TimestampConverter() DateTime date,
    AttendanceStatus status,
    String? comment,
    String? teacherId,
    String? teacherName,
  });
}

/// @nodoc
class _$AttendanceCopyWithImpl<$Res, $Val extends Attendance>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = freezed,
    Object? subject = null,
    Object? date = null,
    Object? status = null,
    Object? comment = freezed,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
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
                freezed == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String?,
            subject:
                null == subject
                    ? _value.subject
                    : subject // ignore: cast_nullable_to_non_nullable
                        as String,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as AttendanceStatus,
            comment:
                freezed == comment
                    ? _value.comment
                    : comment // ignore: cast_nullable_to_non_nullable
                        as String?,
            teacherId:
                freezed == teacherId
                    ? _value.teacherId
                    : teacherId // ignore: cast_nullable_to_non_nullable
                        as String?,
            teacherName:
                freezed == teacherName
                    ? _value.teacherName
                    : teacherName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceImplCopyWith<$Res>
    implements $AttendanceCopyWith<$Res> {
  factory _$$AttendanceImplCopyWith(
    _$AttendanceImpl value,
    $Res Function(_$AttendanceImpl) then,
  ) = __$$AttendanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String? groupId,
    String subject,
    @TimestampConverter() DateTime date,
    AttendanceStatus status,
    String? comment,
    String? teacherId,
    String? teacherName,
  });
}

/// @nodoc
class __$$AttendanceImplCopyWithImpl<$Res>
    extends _$AttendanceCopyWithImpl<$Res, _$AttendanceImpl>
    implements _$$AttendanceImplCopyWith<$Res> {
  __$$AttendanceImplCopyWithImpl(
    _$AttendanceImpl _value,
    $Res Function(_$AttendanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = freezed,
    Object? subject = null,
    Object? date = null,
    Object? status = null,
    Object? comment = freezed,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
  }) {
    return _then(
      _$AttendanceImpl(
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
            freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String?,
        subject:
            null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                    as String,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as AttendanceStatus,
        comment:
            freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                    as String?,
        teacherId:
            freezed == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                    as String?,
        teacherName:
            freezed == teacherName
                ? _value.teacherName
                : teacherName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceImpl implements _Attendance {
  const _$AttendanceImpl({
    required this.studentId,
    this.studentName,
    this.groupId,
    required this.subject,
    @TimestampConverter() required this.date,
    required this.status,
    this.comment,
    this.teacherId,
    this.teacherName,
  });

  factory _$AttendanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceImplFromJson(json);

  @override
  final String studentId;
  @override
  final String? studentName;
  @override
  final String? groupId;
  @override
  final String subject;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final AttendanceStatus status;
  @override
  final String? comment;
  @override
  final String? teacherId;
  @override
  final String? teacherName;

  @override
  String toString() {
    return 'Attendance(studentId: $studentId, studentName: $studentName, groupId: $groupId, subject: $subject, date: $date, status: $status, comment: $comment, teacherId: $teacherId, teacherName: $teacherName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    studentName,
    groupId,
    subject,
    date,
    status,
    comment,
    teacherId,
    teacherName,
  );

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      __$$AttendanceImplCopyWithImpl<_$AttendanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceImplToJson(this);
  }
}

abstract class _Attendance implements Attendance {
  const factory _Attendance({
    required final String studentId,
    final String? studentName,
    final String? groupId,
    required final String subject,
    @TimestampConverter() required final DateTime date,
    required final AttendanceStatus status,
    final String? comment,
    final String? teacherId,
    final String? teacherName,
  }) = _$AttendanceImpl;

  factory _Attendance.fromJson(Map<String, dynamic> json) =
      _$AttendanceImpl.fromJson;

  @override
  String get studentId;
  @override
  String? get studentName;
  @override
  String? get groupId;
  @override
  String get subject;
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  AttendanceStatus get status;
  @override
  String? get comment;
  @override
  String? get teacherId;
  @override
  String? get teacherName;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
