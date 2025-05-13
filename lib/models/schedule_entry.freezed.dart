// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScheduleEntry _$ScheduleEntryFromJson(Map<String, dynamic> json) {
  return _ScheduleEntry.fromJson(json);
}

/// @nodoc
mixin _$ScheduleEntry {
  String? get id =>
      throw _privateConstructorUsedError; // ID документа в Firestore
  int get dayOfWeek =>
      throw _privateConstructorUsedError; // 1=Пн, 2=Вт, ..., 7=Вс
  int get lessonNumber =>
      throw _privateConstructorUsedError; // Номер пары/урока
  String get startTime =>
      throw _privateConstructorUsedError; // Время начала (HH:mm)
  String get endTime =>
      throw _privateConstructorUsedError; // Время конца (HH:mm)
  String get subject => throw _privateConstructorUsedError; // Название предмета
  String? get teacherId =>
      throw _privateConstructorUsedError; // ID преподавателя
  String? get teacherName =>
      throw _privateConstructorUsedError; // Имя преподавателя
  String? get classroom => throw _privateConstructorUsedError; // Аудитория
  String? get lessonType =>
      throw _privateConstructorUsedError; // Тип занятия ("Лекция", "Практика", и т.д.)
  String? get groupId => throw _privateConstructorUsedError;

  /// Serializes this ScheduleEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleEntryCopyWith<ScheduleEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleEntryCopyWith<$Res> {
  factory $ScheduleEntryCopyWith(
    ScheduleEntry value,
    $Res Function(ScheduleEntry) then,
  ) = _$ScheduleEntryCopyWithImpl<$Res, ScheduleEntry>;
  @useResult
  $Res call({
    String? id,
    int dayOfWeek,
    int lessonNumber,
    String startTime,
    String endTime,
    String subject,
    String? teacherId,
    String? teacherName,
    String? classroom,
    String? lessonType,
    String? groupId,
  });
}

/// @nodoc
class _$ScheduleEntryCopyWithImpl<$Res, $Val extends ScheduleEntry>
    implements $ScheduleEntryCopyWith<$Res> {
  _$ScheduleEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? dayOfWeek = null,
    Object? lessonNumber = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? subject = null,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
    Object? classroom = freezed,
    Object? lessonType = freezed,
    Object? groupId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            dayOfWeek:
                null == dayOfWeek
                    ? _value.dayOfWeek
                    : dayOfWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            lessonNumber:
                null == lessonNumber
                    ? _value.lessonNumber
                    : lessonNumber // ignore: cast_nullable_to_non_nullable
                        as int,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as String,
            endTime:
                null == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as String,
            subject:
                null == subject
                    ? _value.subject
                    : subject // ignore: cast_nullable_to_non_nullable
                        as String,
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
            classroom:
                freezed == classroom
                    ? _value.classroom
                    : classroom // ignore: cast_nullable_to_non_nullable
                        as String?,
            lessonType:
                freezed == lessonType
                    ? _value.lessonType
                    : lessonType // ignore: cast_nullable_to_non_nullable
                        as String?,
            groupId:
                freezed == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleEntryImplCopyWith<$Res>
    implements $ScheduleEntryCopyWith<$Res> {
  factory _$$ScheduleEntryImplCopyWith(
    _$ScheduleEntryImpl value,
    $Res Function(_$ScheduleEntryImpl) then,
  ) = __$$ScheduleEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    int dayOfWeek,
    int lessonNumber,
    String startTime,
    String endTime,
    String subject,
    String? teacherId,
    String? teacherName,
    String? classroom,
    String? lessonType,
    String? groupId,
  });
}

/// @nodoc
class __$$ScheduleEntryImplCopyWithImpl<$Res>
    extends _$ScheduleEntryCopyWithImpl<$Res, _$ScheduleEntryImpl>
    implements _$$ScheduleEntryImplCopyWith<$Res> {
  __$$ScheduleEntryImplCopyWithImpl(
    _$ScheduleEntryImpl _value,
    $Res Function(_$ScheduleEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? dayOfWeek = null,
    Object? lessonNumber = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? subject = null,
    Object? teacherId = freezed,
    Object? teacherName = freezed,
    Object? classroom = freezed,
    Object? lessonType = freezed,
    Object? groupId = freezed,
  }) {
    return _then(
      _$ScheduleEntryImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        dayOfWeek:
            null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        lessonNumber:
            null == lessonNumber
                ? _value.lessonNumber
                : lessonNumber // ignore: cast_nullable_to_non_nullable
                    as int,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as String,
        endTime:
            null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as String,
        subject:
            null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                    as String,
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
        classroom:
            freezed == classroom
                ? _value.classroom
                : classroom // ignore: cast_nullable_to_non_nullable
                    as String?,
        lessonType:
            freezed == lessonType
                ? _value.lessonType
                : lessonType // ignore: cast_nullable_to_non_nullable
                    as String?,
        groupId:
            freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleEntryImpl extends _ScheduleEntry {
  const _$ScheduleEntryImpl({
    this.id,
    required this.dayOfWeek,
    required this.lessonNumber,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.teacherId,
    this.teacherName,
    this.classroom,
    this.lessonType,
    this.groupId,
  }) : super._();

  factory _$ScheduleEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleEntryImplFromJson(json);

  @override
  final String? id;
  // ID документа в Firestore
  @override
  final int dayOfWeek;
  // 1=Пн, 2=Вт, ..., 7=Вс
  @override
  final int lessonNumber;
  // Номер пары/урока
  @override
  final String startTime;
  // Время начала (HH:mm)
  @override
  final String endTime;
  // Время конца (HH:mm)
  @override
  final String subject;
  // Название предмета
  @override
  final String? teacherId;
  // ID преподавателя
  @override
  final String? teacherName;
  // Имя преподавателя
  @override
  final String? classroom;
  // Аудитория
  @override
  final String? lessonType;
  // Тип занятия ("Лекция", "Практика", и т.д.)
  @override
  final String? groupId;

  @override
  String toString() {
    return 'ScheduleEntry(id: $id, dayOfWeek: $dayOfWeek, lessonNumber: $lessonNumber, startTime: $startTime, endTime: $endTime, subject: $subject, teacherId: $teacherId, teacherName: $teacherName, classroom: $classroom, lessonType: $lessonType, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.lessonNumber, lessonNumber) ||
                other.lessonNumber == lessonNumber) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.classroom, classroom) ||
                other.classroom == classroom) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dayOfWeek,
    lessonNumber,
    startTime,
    endTime,
    subject,
    teacherId,
    teacherName,
    classroom,
    lessonType,
    groupId,
  );

  /// Create a copy of ScheduleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleEntryImplCopyWith<_$ScheduleEntryImpl> get copyWith =>
      __$$ScheduleEntryImplCopyWithImpl<_$ScheduleEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleEntryImplToJson(this);
  }
}

abstract class _ScheduleEntry extends ScheduleEntry {
  const factory _ScheduleEntry({
    final String? id,
    required final int dayOfWeek,
    required final int lessonNumber,
    required final String startTime,
    required final String endTime,
    required final String subject,
    final String? teacherId,
    final String? teacherName,
    final String? classroom,
    final String? lessonType,
    final String? groupId,
  }) = _$ScheduleEntryImpl;
  const _ScheduleEntry._() : super._();

  factory _ScheduleEntry.fromJson(Map<String, dynamic> json) =
      _$ScheduleEntryImpl.fromJson;

  @override
  String? get id; // ID документа в Firestore
  @override
  int get dayOfWeek; // 1=Пн, 2=Вт, ..., 7=Вс
  @override
  int get lessonNumber; // Номер пары/урока
  @override
  String get startTime; // Время начала (HH:mm)
  @override
  String get endTime; // Время конца (HH:mm)
  @override
  String get subject; // Название предмета
  @override
  String? get teacherId; // ID преподавателя
  @override
  String? get teacherName; // Имя преподавателя
  @override
  String? get classroom; // Аудитория
  @override
  String? get lessonType; // Тип занятия ("Лекция", "Практика", и т.д.)
  @override
  String? get groupId;

  /// Create a copy of ScheduleEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleEntryImplCopyWith<_$ScheduleEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
