// lib/core/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart'
    hide User; // Скрываем User из firebase_auth
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint

// Импортируем нашу модель User без псевдонима, если нет конфликтов
// или используем 'as app_user' если есть конфликт имен
import '../models/user.dart';

// --- Riverpod Провайдеры ---

// Провайдер для самого сервиса
final authServiceProvider = Provider((ref) => AuthService());

// Провайдер для стрима состояния аутентификации с данными пользователя
final authStateProvider = StreamProvider<User?>((ref) {
  // Следим за authServiceProvider, чтобы получить экземпляр AuthService
  final authService = ref.watch(authServiceProvider);
  return authService
      .authStateChanges; // Возвращаем стрим кастомного пользователя
});

// --- Класс Сервиса Аутентификации ---

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Стрим, который выдает нашего кастомного пользователя [User] или null.
  Stream<User?> userStream() {
    // Слушаем изменения состояния в Firebase Auth
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      // Используем debugPrint для логов, они не попадают в релизный билд
      debugPrint(
        '[AuthService] AuthState изменился. Firebase User ID: ${firebaseUser?.uid}',
      );
      if (firebaseUser == null) {
        // Если пользователя нет в Firebase Auth, возвращаем null
        return null;
      }
      // Если пользователь есть, пытаемся получить его данные из Firestore
      final appUser = await _getUserData(firebaseUser.uid);
      debugPrint(
        '[AuthService] Получен app_user: ${appUser?.id}, role: ${appUser?.role}',
      );
      return appUser; // Возвращаем нашего пользователя или null, если данных нет
    });
  }

  /// Вспомогательный метод для загрузки данных пользователя из Firestore.
  Future<User?> _getUserData(String uid) async {
    try {
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);
      debugPrint('[AuthService] Пытаюсь получить документ: ${userDocRef.path}');
      final DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        debugPrint('[AuthService] Документ пользователя $uid существует.');
        // Получаем данные как Map<String, dynamic>
        final userData = userDoc.data() as Map<String, dynamic>;
        debugPrint('[AuthService] Данные пользователя $uid: $userData');

        // Явно добавляем ID документа в Map перед передачей в fromJson,
        // если User.fromJson ожидает поле 'id'.
        userData['id'] = uid;

        // Создаем наш объект User из данных Firestore
        return User.fromJson(userData);
      } else {
        // Документа нет - это может быть проблемой (например, ошибка при записи во время регистрации)
        debugPrint(
          '[AuthService] ОШИБКА: Документ пользователя $uid НЕ НАЙДЕН в Firestore.',
        );
        return null;
      }
    } on FirebaseException catch (e) {
      // Ошибка при чтении из Firestore (например, нет прав доступа)
      debugPrint(
        '[AuthService] ОШИБКА Firestore при получении данных пользователя $uid: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      // Любая другая неожиданная ошибка
      debugPrint(
        '[AuthService] НЕИЗВЕСТНАЯ ОШИБКА при получении данных пользователя $uid: $e',
      );
      return null;
    }
  }

  /// Вход пользователя по email и паролю.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('[AuthService] Попытка входа для: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Регистрация нового пользователя с email, паролем, именем и ролью.
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
    // --- Принимаем раздельные ФИО ---
    String lastName,
    String firstName,
    String? patronymic, // Отчество опционально
    // --------------------------------
    String role,
  ) async {
    try {
      debugPrint('[AuthService] Попытка регистрации для: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        debugPrint(
          '[AuthService] Пользователь создан в Auth: ${firebaseUser.uid}',
        );
        // --- Сохраняем раздельные ФИО в Firestore ---
        final userData = {
          'lastName': lastName.trim(), // Убираем лишние пробелы
          'firstName': firstName.trim(),
          'patronymic':
              patronymic?.trim() ?? '', // Сохраняем пустоту, если null
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          // Добавь сюда другие поля по умолчанию, если нужно (groupId, course и т.д.
          // могут добавляться позже админом или при привязке к группе)
        };
        // ------------------------------------------

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              // Добавляем 'id' в данные перед сохранением, если fromJson его ожидает
              // .set({...userData, 'id': firebaseUser.uid});
              .set(userData); // Используем set
          debugPrint(
            '[AuthService] Данные пользователя ${firebaseUser.uid} сохранены в Firestore.',
          );
        } on FirebaseException catch (e) {
          debugPrint(
            '[AuthService] ОШИБКА Firestore при сохранении данных пользователя ${firebaseUser.uid}: ${e.code} - ${e.message}',
          );
          // ... (обработка ошибки сохранения) ...
        }
        return credential;
      } else {
        // Это не должно произойти, если createUserWithEmailAndPassword не выбросил исключение
        debugPrint(
          '[AuthService] ОШИБКА: credential.user == null после регистрации.',
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Обрабатываем ошибки создания пользователя (слабый пароль, email уже используется и т.д.)
      debugPrint(
        '[AuthService] ОШИБКА FirebaseAuth при регистрации: ${e.code} - ${e.message}',
      );
      return null; // Возвращаем null при ошибке
    } catch (e) {
      debugPrint('[AuthService] НЕИЗВЕСТНАЯ ОШИБКА при регистрации: $e');
      return null;
    }
  }

  /// Выход пользователя.
  Future<void> signOut() async {
    try {
      debugPrint('[AuthService] Выход пользователя...');
      await _auth.signOut();
      debugPrint('[AuthService] Выход выполнен.');
    } catch (e) {
      debugPrint('[AuthService] ОШИБКА при выходе: $e');
    }
  }

  // --- Другие методы сервиса (если нужны) ---
  // Например: сброс пароля, обновление профиля и т.д.
}
