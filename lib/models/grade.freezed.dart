// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Grade _$GradeFromJson(Map<String, dynamic> json) {
  return _Grade.fromJson(json);
}

/// @nodoc
mixin _$Grade {
  // ID можно не хранить, т.к. это ID документа Firestore
  // String? gradeId,
  String get studentId => throw _privateConstructorUsedError;
  String? get studentName =>
      throw _privateConstructorUsedError; // Имя студента (денормализовано)
  String? get groupId =>
      throw _privateConstructorUsedError; // ID группы (денормализовано)
  String get subject => throw _privateConstructorUsedError; // Предмет
  String get grade =>
      throw _privateConstructorUsedError; // Оценка (как строка, чтобы поддерживать '5', 'A', 'Зачет')
  String? get gradeType =>
      throw _privateConstructorUsedError; // Тип оценки: "Экзамен", "Контрольная", и т.д.
  String? get comment =>
      throw _privateConstructorUsedError; // Комментарий преподавателя
  // Используем DateTime и конвертер для поля даты
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String? get teacherId =>
      throw _privateConstructorUsedError; // ID преподавателя
  String? get teacherName => throw _privateConstructorUsedError;

  /// Serializes this Grade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GradeCopyWith<Grade> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradeCopyWith<$Res> {
  factory $GradeCopyWith(Grade value, $Res Function(Grade) then) =
      _$GradeCopyWithImpl<$Res, Grade>;
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String? groupId,
    String subject,
    String grade,
    String? gradeType,
    String? comment,
    @TimestampConverter() DateTime date,
    String? teacherId,
    String? teacherName,
  });
}

/// @nodoc
class _$GradeCopyWithImpl<$Res, $Val extends Grade>
    implements $GradeCopyWith<$Res> {
  _$GradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = freezed,
    Object? subject = null,
    Object? grade = null,
    Object? gradeType = freezed,
    Object? comment = freezed,
    Object? date = null,
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
            grade:
                null == grade
                    ? _value.grade
                    : grade // ignore: cast_nullable_to_non_nullable
                        as String,
            gradeType:
                freezed == gradeType
                    ? _value.gradeType
                    : gradeType // ignore: cast_nullable_to_non_nullable
                        as String?,
            comment:
                freezed == comment
                    ? _value.comment
                    : comment // ignore: cast_nullable_to_non_nullable
                        as String?,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
abstract class _$$GradeImplCopyWith<$Res> implements $GradeCopyWith<$Res> {
  factory _$$GradeImplCopyWith(
    _$GradeImpl value,
    $Res Function(_$GradeImpl) then,
  ) = __$$GradeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String? studentName,
    String? groupId,
    String subject,
    String grade,
    String? gradeType,
    String? comment,
    @TimestampConverter() DateTime date,
    String? teacherId,
    String? teacherName,
  });
}

/// @nodoc
class __$$GradeImplCopyWithImpl<$Res>
    extends _$GradeCopyWithImpl<$Res, _$GradeImpl>
    implements _$$GradeImplCopyWith<$Res> {
  __$$GradeImplCopyWithImpl(
    _$GradeImpl _value,
    $Res Function(_$GradeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = freezed,
    Object? groupId = freezed,
    Object? subject = null,
    Object? grade = null,
    Object? gradeType = freezed,
    Object? comment = freezed,
    Object? date = null,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
  }) {
    return _then(
      _$GradeImpl(
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
        grade:
            null == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                    as String,
        gradeType:
            freezed == gradeType
                ? _value.gradeType
                : gradeType // ignore: cast_nullable_to_non_nullable
                    as String?,
        comment:
            freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                    as String?,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
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
class _$GradeImpl implements _Grade {
  const _$GradeImpl({
    required this.studentId,
    this.studentName,
    this.groupId,
    required this.subject,
    required this.grade,
    this.gradeType,
    this.comment,
    @TimestampConverter() required this.date,
    this.teacherId,
    this.teacherName,
  });

  factory _$GradeImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradeImplFromJson(json);

  // ID можно не хранить, т.к. это ID документа Firestore
  // String? gradeId,
  @override
  final String studentId;
  @override
  final String? studentName;
  // Имя студента (денормализовано)
  @override
  final String? groupId;
  // ID группы (денормализовано)
  @override
  final String subject;
  // Предмет
  @override
  final String grade;
  // Оценка (как строка, чтобы поддерживать '5', 'A', 'Зачет')
  @override
  final String? gradeType;
  // Тип оценки: "Экзамен", "Контрольная", и т.д.
  @override
  final String? comment;
  // Комментарий преподавателя
  // Используем DateTime и конвертер для поля даты
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final String? teacherId;
  // ID преподавателя
  @override
  final String? teacherName;

  @override
  String toString() {
    return 'Grade(studentId: $studentId, studentName: $studentName, groupId: $groupId, subject: $subject, grade: $grade, gradeType: $gradeType, comment: $comment, date: $date, teacherId: $teacherId, teacherName: $teacherName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradeImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.gradeType, gradeType) ||
                other.gradeType == gradeType) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.date, date) || other.date == date) &&
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
    grade,
    gradeType,
    comment,
    date,
    teacherId,
    teacherName,
  );

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GradeImplCopyWith<_$GradeImpl> get copyWith =>
      __$$GradeImplCopyWithImpl<_$GradeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradeImplToJson(this);
  }
}

abstract class _Grade implements Grade {
  const factory _Grade({
    required final String studentId,
    final String? studentName,
    final String? groupId,
    required final String subject,
    required final String grade,
    final String? gradeType,
    final String? comment,
    @TimestampConverter() required final DateTime date,
    final String? teacherId,
    final String? teacherName,
  }) = _$GradeImpl;

  factory _Grade.fromJson(Map<String, dynamic> json) = _$GradeImpl.fromJson;

  // ID можно не хранить, т.к. это ID документа Firestore
  // String? gradeId,
  @override
  String get studentId;
  @override
  String? get studentName; // Имя студента (денормализовано)
  @override
  String? get groupId; // ID группы (денормализовано)
  @override
  String get subject; // Предмет
  @override
  String get grade; // Оценка (как строка, чтобы поддерживать '5', 'A', 'Зачет')
  @override
  String? get gradeType; // Тип оценки: "Экзамен", "Контрольная", и т.д.
  @override
  String? get comment; // Комментарий преподавателя
  // Используем DateTime и конвертер для поля даты
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  String? get teacherId; // ID преподавателя
  @override
  String? get teacherName;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GradeImplCopyWith<_$GradeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
