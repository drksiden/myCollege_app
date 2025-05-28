// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subject _$SubjectFromJson(Map<String, dynamic> json) {
  return _Subject.fromJson(json);
}

/// @nodoc
mixin _$Subject {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get credits => throw _privateConstructorUsedError;
  int get hours => throw _privateConstructorUsedError;
  int get hoursPerSemester => throw _privateConstructorUsedError;
  int get hoursPerWeek => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<String> get groups => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectCopyWith<Subject> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectCopyWith<$Res> {
  factory $SubjectCopyWith(Subject value, $Res Function(Subject) then) =
      _$SubjectCopyWithImpl<$Res, Subject>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int credits,
    int hours,
    int hoursPerSemester,
    int hoursPerWeek,
    String teacherId,
    String type,
    List<String> groups,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubjectCopyWithImpl<$Res, $Val extends Subject>
    implements $SubjectCopyWith<$Res> {
  _$SubjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? credits = null,
    Object? hours = null,
    Object? hoursPerSemester = null,
    Object? hoursPerWeek = null,
    Object? teacherId = null,
    Object? type = null,
    Object? groups = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            credits:
                null == credits
                    ? _value.credits
                    : credits // ignore: cast_nullable_to_non_nullable
                        as int,
            hours:
                null == hours
                    ? _value.hours
                    : hours // ignore: cast_nullable_to_non_nullable
                        as int,
            hoursPerSemester:
                null == hoursPerSemester
                    ? _value.hoursPerSemester
                    : hoursPerSemester // ignore: cast_nullable_to_non_nullable
                        as int,
            hoursPerWeek:
                null == hoursPerWeek
                    ? _value.hoursPerWeek
                    : hoursPerWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            teacherId:
                null == teacherId
                    ? _value.teacherId
                    : teacherId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            groups:
                null == groups
                    ? _value.groups
                    : groups // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectImplCopyWith<$Res> implements $SubjectCopyWith<$Res> {
  factory _$$SubjectImplCopyWith(
    _$SubjectImpl value,
    $Res Function(_$SubjectImpl) then,
  ) = __$$SubjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int credits,
    int hours,
    int hoursPerSemester,
    int hoursPerWeek,
    String teacherId,
    String type,
    List<String> groups,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubjectImplCopyWithImpl<$Res>
    extends _$SubjectCopyWithImpl<$Res, _$SubjectImpl>
    implements _$$SubjectImplCopyWith<$Res> {
  __$$SubjectImplCopyWithImpl(
    _$SubjectImpl _value,
    $Res Function(_$SubjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? credits = null,
    Object? hours = null,
    Object? hoursPerSemester = null,
    Object? hoursPerWeek = null,
    Object? teacherId = null,
    Object? type = null,
    Object? groups = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubjectImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        credits:
            null == credits
                ? _value.credits
                : credits // ignore: cast_nullable_to_non_nullable
                    as int,
        hours:
            null == hours
                ? _value.hours
                : hours // ignore: cast_nullable_to_non_nullable
                    as int,
        hoursPerSemester:
            null == hoursPerSemester
                ? _value.hoursPerSemester
                : hoursPerSemester // ignore: cast_nullable_to_non_nullable
                    as int,
        hoursPerWeek:
            null == hoursPerWeek
                ? _value.hoursPerWeek
                : hoursPerWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        teacherId:
            null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        groups:
            null == groups
                ? _value._groups
                : groups // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectImpl implements _Subject {
  const _$SubjectImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.hours,
    required this.hoursPerSemester,
    required this.hoursPerWeek,
    required this.teacherId,
    required this.type,
    required final List<String> groups,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.updatedAt,
  }) : _groups = groups;

  factory _$SubjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int credits;
  @override
  final int hours;
  @override
  final int hoursPerSemester;
  @override
  final int hoursPerWeek;
  @override
  final String teacherId;
  @override
  final String type;
  final List<String> _groups;
  @override
  List<String> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, description: $description, credits: $credits, hours: $hours, hoursPerSemester: $hoursPerSemester, hoursPerWeek: $hoursPerWeek, teacherId: $teacherId, type: $type, groups: $groups, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.credits, credits) || other.credits == credits) &&
            (identical(other.hours, hours) || other.hours == hours) &&
            (identical(other.hoursPerSemester, hoursPerSemester) ||
                other.hoursPerSemester == hoursPerSemester) &&
            (identical(other.hoursPerWeek, hoursPerWeek) ||
                other.hoursPerWeek == hoursPerWeek) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    credits,
    hours,
    hoursPerSemester,
    hoursPerWeek,
    teacherId,
    type,
    const DeepCollectionEquality().hash(_groups),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectImplCopyWith<_$SubjectImpl> get copyWith =>
      __$$SubjectImplCopyWithImpl<_$SubjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectImplToJson(this);
  }
}

abstract class _Subject implements Subject {
  const factory _Subject({
    required final String id,
    required final String name,
    required final String description,
    required final int credits,
    required final int hours,
    required final int hoursPerSemester,
    required final int hoursPerWeek,
    required final String teacherId,
    required final String type,
    required final List<String> groups,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime updatedAt,
  }) = _$SubjectImpl;

  factory _Subject.fromJson(Map<String, dynamic> json) = _$SubjectImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get credits;
  @override
  int get hours;
  @override
  int get hoursPerSemester;
  @override
  int get hoursPerWeek;
  @override
  String get teacherId;
  @override
  String get type;
  @override
  List<String> get groups;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get updatedAt;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectImplCopyWith<_$SubjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
