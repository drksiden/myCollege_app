// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  lastName: json['lastName'] as String,
  firstName: json['firstName'] as String,
  patronymic: json['patronymic'] as String?,
  email: json['email'] as String,
  role: json['role'] as String,
  profilePicture: json['profilePicture'] as String?,
  groupId: json['groupId'] as String?,
  course: (json['course'] as num?)?.toInt(),
  groupName: json['groupName'] as String?,
  specialty: json['specialty'] as String?,
  phone: json['phone'] as String?,
  attendance: (json['attendance'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
      'patronymic': instance.patronymic,
      'email': instance.email,
      'role': instance.role,
      'profilePicture': instance.profilePicture,
      'groupId': instance.groupId,
      'course': instance.course,
      'groupName': instance.groupName,
      'specialty': instance.specialty,
      'phone': instance.phone,
      'attendance': instance.attendance,
    };
