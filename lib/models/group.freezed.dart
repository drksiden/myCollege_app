// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  // Применяем аннотацию к параметру конструктора.
  // Freezed должен корректно обработать это для генерируемого поля.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id => throw _privateConstructorUsedError;
  String get name =>
      throw _privateConstructorUsedError; // Название группы (П4А)
  String get teacherId =>
      throw _privateConstructorUsedError; // UID куратора/преподавателя группы
  String? get teacherName =>
      throw _privateConstructorUsedError; // Имя куратора (для отображения)
  String get specialty => throw _privateConstructorUsedError; // Специальность
  int get course => throw _privateConstructorUsedError; // Курс
  // Список предметов (важно для фильтра в журнале)
  List<String> get subjects => throw _privateConstructorUsedError;

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String name,
    String teacherId,
    String? teacherName,
    String specialty,
    int course,
    List<String> subjects,
  });
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? teacherId = null,
    Object? teacherName = freezed,
    Object? specialty = null,
    Object? course = null,
    Object? subjects = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
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
            specialty:
                null == specialty
                    ? _value.specialty
                    : specialty // ignore: cast_nullable_to_non_nullable
                        as String,
            course:
                null == course
                    ? _value.course
                    : course // ignore: cast_nullable_to_non_nullable
                        as int,
            subjects:
                null == subjects
                    ? _value.subjects
                    : subjects // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
    _$GroupImpl value,
    $Res Function(_$GroupImpl) then,
  ) = __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String name,
    String teacherId,
    String? teacherName,
    String specialty,
    int course,
    List<String> subjects,
  });
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
    _$GroupImpl _value,
    $Res Function(_$GroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? teacherId = null,
    Object? teacherName = freezed,
    Object? specialty = null,
    Object? course = null,
    Object? subjects = null,
  }) {
    return _then(
      _$GroupImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
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
        specialty:
            null == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                    as String,
        course:
            null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                    as int,
        subjects:
            null == subjects
                ? _value._subjects
                : subjects // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl({
    @JsonKey(includeFromJson: false, includeToJson: false) this.id,
    required this.name,
    required this.teacherId,
    this.teacherName,
    required this.specialty,
    required this.course,
    required final List<String> subjects,
  }) : _subjects = subjects;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  // Применяем аннотацию к параметру конструктора.
  // Freezed должен корректно обработать это для генерируемого поля.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  @override
  final String name;
  // Название группы (П4А)
  @override
  final String teacherId;
  // UID куратора/преподавателя группы
  @override
  final String? teacherName;
  // Имя куратора (для отображения)
  @override
  final String specialty;
  // Специальность
  @override
  final int course;
  // Курс
  // Список предметов (важно для фильтра в журнале)
  final List<String> _subjects;
  // Курс
  // Список предметов (важно для фильтра в журнале)
  @override
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, teacherId: $teacherId, teacherName: $teacherName, specialty: $specialty, course: $course, subjects: $subjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.course, course) || other.course == course) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    teacherId,
    teacherName,
    specialty,
    course,
    const DeepCollectionEquality().hash(_subjects),
  );

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(this);
  }
}

abstract class _Group implements Group {
  const factory _Group({
    @JsonKey(includeFromJson: false, includeToJson: false) final String? id,
    required final String name,
    required final String teacherId,
    final String? teacherName,
    required final String specialty,
    required final int course,
    required final List<String> subjects,
  }) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  // Применяем аннотацию к параметру конструктора.
  // Freezed должен корректно обработать это для генерируемого поля.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id;
  @override
  String get name; // Название группы (П4А)
  @override
  String get teacherId; // UID куратора/преподавателя группы
  @override
  String? get teacherName; // Имя куратора (для отображения)
  @override
  String get specialty; // Специальность
  @override
  int get course; // Курс
  // Список предметов (важно для фильтра в журнале)
  @override
  List<String> get subjects;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
