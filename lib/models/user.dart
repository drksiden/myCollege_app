// lib/models/user.dart (Исправленный с getter в extension)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    // --- Раздельные поля ФИО ---
    required String lastName, // Фамилия
    required String firstName, // Имя
    String? patronymic, // Отчество (опционально)
    // --------------------------
    required String email,
    required String role,
    String? profilePicture,
    String? groupId,
    int? course,
    String? groupName,
    String? specialty,
    String? phone,
    Map<String, String>? attendance,
    // Timestamp? createdAt,
  }) = _User; // Убедись, что имя приватного класса совпадает (_User)

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // --- УБИРАЕМ GETTER ОТСЮДА ---
  // String get fullName { ... }
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