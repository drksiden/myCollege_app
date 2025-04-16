// lib/models/user_profile.dart
class UserProfile {
  final String id; // Может понадобиться позже для ID из Firebase Auth
  final String name;
  final String studentId;
  final int age; // Используем int для возраста
  final int course; // Используем int для курса
  final String specialty;
  final String group;
  final String profileImageUrl;
  final String email; // Добавим email
  final String phone; // Добавим телефон (опционально)

  UserProfile({
    required this.id,
    required this.name,
    required this.studentId,
    required this.age,
    required this.course,
    required this.specialty,
    required this.group,
    this.profileImageUrl = '', // По умолчанию пусто
    this.email = '',
    this.phone = '',
  });
}
