// lib/models/user.dart (Исправленный с getter в extension)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id, // Соответствует uid в BaseUser
    required String lastName,
    required String firstName,
    String? patronymic, // Соответствует middleName в BaseUser
    required String email,
    required String role, // Строка, должна соответствовать значениям UserRole
    String? profilePicture, // Соответствует photoURL в BaseUser
    String? groupId, // Специфично для студента
    int? course, // Было в Group, теперь здесь для User?
    String? groupName, // Денормализованное поле для отображения
    String?
    specialty, // Может быть специализацией преподавателя или студента (денорм.)
    String? phone, // Соответствует phone в BaseUser
    Map<String, String>? attendance, // Новое поле, не обсуждалось ранее
    @Default('pending_approval')
    String status, // Статус пользователя: pending_approval, active, rejected
    // Timestamp? createdAt,   // Закомментировано, но ОЧЕНЬ ВАЖНО
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// --- ДОБАВЛЯЕМ GETTER В EXTENSION ПОСЛЕ КЛАССА ---
extension UserFullNameGetter on User {
  /// Возвращает полное имя в формате "Фамилия Имя Отчество"
  String get fullName {
    // Здесь мы имеем доступ к полям lastName, firstName, patronymic
    final parts = [lastName, firstName, patronymic];
    return parts
        .where(
          (part) => part != null && part.isNotEmpty,
        ) // Фильтруем null и пустые строки
        .join(' '); // Соединяем через пробел
  }

  /// Пример: Возвращает имя в формате "И. О. Фамилия" (если нужно)
  String get shortName {
    final initialFirstName = firstName.isNotEmpty ? '${firstName[0]}.' : '';
    final initialPatronymic =
        (patronymic != null && patronymic!.isNotEmpty)
            ? '${patronymic![0]}.'
            : '';
    return '$initialFirstName $initialPatronymic $lastName'.trim();
  }
}
// ----------------------------------------------------