// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id =>
      throw _privateConstructorUsedError; // Соответствует uid в BaseUser
  String get lastName => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get patronymic =>
      throw _privateConstructorUsedError; // Соответствует middleName в BaseUser
  String get email => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // Строка, должна соответствовать значениям UserRole
  String? get profilePicture =>
      throw _privateConstructorUsedError; // Соответствует photoURL в BaseUser
  String? get groupId =>
      throw _privateConstructorUsedError; // Специфично для студента
  int? get course =>
      throw _privateConstructorUsedError; // Было в Group, теперь здесь для User?
  String? get groupName =>
      throw _privateConstructorUsedError; // Денормализованное поле для отображения
  String? get specialty =>
      throw _privateConstructorUsedError; // Может быть специализацией преподавателя или студента (денорм.)
  String? get phone =>
      throw _privateConstructorUsedError; // Соответствует phone в BaseUser
  Map<String, String>? get attendance =>
      throw _privateConstructorUsedError; // Новое поле, не обсуждалось ранее
  String get status => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String lastName,
    String firstName,
    String? patronymic,
    String email,
    String role,
    String? profilePicture,
    String? groupId,
    int? course,
    String? groupName,
    String? specialty,
    String? phone,
    Map<String, String>? attendance,
    String status,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lastName = null,
    Object? firstName = null,
    Object? patronymic = freezed,
    Object? email = null,
    Object? role = null,
    Object? profilePicture = freezed,
    Object? groupId = freezed,
    Object? course = freezed,
    Object? groupName = freezed,
    Object? specialty = freezed,
    Object? phone = freezed,
    Object? attendance = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            lastName:
                null == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String,
            firstName:
                null == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String,
            patronymic:
                freezed == patronymic
                    ? _value.patronymic
                    : patronymic // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as String,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as String?,
            groupId:
                freezed == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String?,
            course:
                freezed == course
                    ? _value.course
                    : course // ignore: cast_nullable_to_non_nullable
                        as int?,
            groupName:
                freezed == groupName
                    ? _value.groupName
                    : groupName // ignore: cast_nullable_to_non_nullable
                        as String?,
            specialty:
                freezed == specialty
                    ? _value.specialty
                    : specialty // ignore: cast_nullable_to_non_nullable
                        as String?,
            phone:
                freezed == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String?,
            attendance:
                freezed == attendance
                    ? _value.attendance
                    : attendance // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String lastName,
    String firstName,
    String? patronymic,
    String email,
    String role,
    String? profilePicture,
    String? groupId,
    int? course,
    String? groupName,
    String? specialty,
    String? phone,
    Map<String, String>? attendance,
    String status,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lastName = null,
    Object? firstName = null,
    Object? patronymic = freezed,
    Object? email = null,
    Object? role = null,
    Object? profilePicture = freezed,
    Object? groupId = freezed,
    Object? course = freezed,
    Object? groupName = freezed,
    Object? specialty = freezed,
    Object? phone = freezed,
    Object? attendance = freezed,
    Object? status = null,
  }) {
    return _then(
      _$UserImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        lastName:
            null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String,
        firstName:
            null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String,
        patronymic:
            freezed == patronymic
                ? _value.patronymic
                : patronymic // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as String,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as String?,
        groupId:
            freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String?,
        course:
            freezed == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                    as int?,
        groupName:
            freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                    as String?,
        specialty:
            freezed == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                    as String?,
        phone:
            freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String?,
        attendance:
            freezed == attendance
                ? _value._attendance
                : attendance // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.patronymic,
    required this.email,
    required this.role,
    this.profilePicture,
    this.groupId,
    this.course,
    this.groupName,
    this.specialty,
    this.phone,
    final Map<String, String>? attendance,
    this.status = 'pending_approval',
  }) : _attendance = attendance;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  // Соответствует uid в BaseUser
  @override
  final String lastName;
  @override
  final String firstName;
  @override
  final String? patronymic;
  // Соответствует middleName в BaseUser
  @override
  final String email;
  @override
  final String role;
  // Строка, должна соответствовать значениям UserRole
  @override
  final String? profilePicture;
  // Соответствует photoURL в BaseUser
  @override
  final String? groupId;
  // Специфично для студента
  @override
  final int? course;
  // Было в Group, теперь здесь для User?
  @override
  final String? groupName;
  // Денормализованное поле для отображения
  @override
  final String? specialty;
  // Может быть специализацией преподавателя или студента (денорм.)
  @override
  final String? phone;
  // Соответствует phone в BaseUser
  final Map<String, String>? _attendance;
  // Соответствует phone в BaseUser
  @override
  Map<String, String>? get attendance {
    final value = _attendance;
    if (value == null) return null;
    if (_attendance is EqualUnmodifiableMapView) return _attendance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Новое поле, не обсуждалось ранее
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'User(id: $id, lastName: $lastName, firstName: $firstName, patronymic: $patronymic, email: $email, role: $role, profilePicture: $profilePicture, groupId: $groupId, course: $course, groupName: $groupName, specialty: $specialty, phone: $phone, attendance: $attendance, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.patronymic, patronymic) ||
                other.patronymic == patronymic) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            const DeepCollectionEquality().equals(
              other._attendance,
              _attendance,
            ) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    lastName,
    firstName,
    patronymic,
    email,
    role,
    profilePicture,
    groupId,
    course,
    groupName,
    specialty,
    phone,
    const DeepCollectionEquality().hash(_attendance),
    status,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String lastName,
    required final String firstName,
    final String? patronymic,
    required final String email,
    required final String role,
    final String? profilePicture,
    final String? groupId,
    final int? course,
    final String? groupName,
    final String? specialty,
    final String? phone,
    final Map<String, String>? attendance,
    final String status,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id; // Соответствует uid в BaseUser
  @override
  String get lastName;
  @override
  String get firstName;
  @override
  String? get patronymic; // Соответствует middleName в BaseUser
  @override
  String get email;
  @override
  String get role; // Строка, должна соответствовать значениям UserRole
  @override
  String? get profilePicture; // Соответствует photoURL в BaseUser
  @override
  String? get groupId; // Специфично для студента
  @override
  int? get course; // Было в Group, теперь здесь для User?
  @override
  String? get groupName; // Денормализованное поле для отображения
  @override
  String? get specialty; // Может быть специализацией преподавателя или студента (денорм.)
  @override
  String? get phone; // Соответствует phone в BaseUser
  @override
  Map<String, String>? get attendance; // Новое поле, не обсуждалось ранее
  @override
  String get status;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
