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
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get specialization =>
      throw _privateConstructorUsedError; // Специализация
  int get year => throw _privateConstructorUsedError; // Курс
  String? get description => throw _privateConstructorUsedError;
  String? get curatorId => throw _privateConstructorUsedError; // ID куратора
  String? get curatorName => throw _privateConstructorUsedError; // Имя куратора
  List<String>? get studentIds =>
      throw _privateConstructorUsedError; // Список ID студентов
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
    String id,
    String name,
    String specialization,
    int year,
    String? description,
    String? curatorId,
    String? curatorName,
    List<String>? studentIds,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
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
    Object? id = null,
    Object? name = null,
    Object? specialization = null,
    Object? year = null,
    Object? description = freezed,
    Object? curatorId = freezed,
    Object? curatorName = freezed,
    Object? studentIds = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            specialization:
                null == specialization
                    ? _value.specialization
                    : specialization // ignore: cast_nullable_to_non_nullable
                        as String,
            year:
                null == year
                    ? _value.year
                    : year // ignore: cast_nullable_to_non_nullable
                        as int,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            curatorId:
                freezed == curatorId
                    ? _value.curatorId
                    : curatorId // ignore: cast_nullable_to_non_nullable
                        as String?,
            curatorName:
                freezed == curatorName
                    ? _value.curatorName
                    : curatorName // ignore: cast_nullable_to_non_nullable
                        as String?,
            studentIds:
                freezed == studentIds
                    ? _value.studentIds
                    : studentIds // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
    String id,
    String name,
    String specialization,
    int year,
    String? description,
    String? curatorId,
    String? curatorName,
    List<String>? studentIds,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
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
    Object? id = null,
    Object? name = null,
    Object? specialization = null,
    Object? year = null,
    Object? description = freezed,
    Object? curatorId = freezed,
    Object? curatorName = freezed,
    Object? studentIds = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$GroupImpl(
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
        specialization:
            null == specialization
                ? _value.specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                    as String,
        year:
            null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                    as int,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        curatorId:
            freezed == curatorId
                ? _value.curatorId
                : curatorId // ignore: cast_nullable_to_non_nullable
                    as String?,
        curatorName:
            freezed == curatorName
                ? _value.curatorName
                : curatorName // ignore: cast_nullable_to_non_nullable
                    as String?,
        studentIds:
            freezed == studentIds
                ? _value._studentIds
                : studentIds // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl({
    required this.id,
    required this.name,
    required this.specialization,
    required this.year,
    this.description,
    this.curatorId,
    this.curatorName,
    final List<String>? studentIds,
    @TimestampConverter() this.createdAt,
    @TimestampConverter() this.updatedAt,
  }) : _studentIds = studentIds;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String specialization;
  // Специализация
  @override
  final int year;
  // Курс
  @override
  final String? description;
  @override
  final String? curatorId;
  // ID куратора
  @override
  final String? curatorName;
  // Имя куратора
  final List<String>? _studentIds;
  // Имя куратора
  @override
  List<String>? get studentIds {
    final value = _studentIds;
    if (value == null) return null;
    if (_studentIds is EqualUnmodifiableListView) return _studentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Список ID студентов
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Group(id: $id, name: $name, specialization: $specialization, year: $year, description: $description, curatorId: $curatorId, curatorName: $curatorName, studentIds: $studentIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.curatorId, curatorId) ||
                other.curatorId == curatorId) &&
            (identical(other.curatorName, curatorName) ||
                other.curatorName == curatorName) &&
            const DeepCollectionEquality().equals(
              other._studentIds,
              _studentIds,
            ) &&
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
    specialization,
    year,
    description,
    curatorId,
    curatorName,
    const DeepCollectionEquality().hash(_studentIds),
    createdAt,
    updatedAt,
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
    required final String id,
    required final String name,
    required final String specialization,
    required final int year,
    final String? description,
    final String? curatorId,
    final String? curatorName,
    final List<String>? studentIds,
    @TimestampConverter() final DateTime? createdAt,
    @TimestampConverter() final DateTime? updatedAt,
  }) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get specialization; // Специализация
  @override
  int get year; // Курс
  @override
  String? get description;
  @override
  String? get curatorId; // ID куратора
  @override
  String? get curatorName; // Имя куратора
  @override
  List<String>? get studentIds; // Список ID студентов
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
