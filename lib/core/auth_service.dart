// lib/core/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart'
    hide User; // Скрываем User из firebase_auth
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint

import '../models/user.dart' as app; // Используем псевдоним 'app'

// --- Riverpod Провайдеры ---
final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<app.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService
      .userStream(); // Используем userStream для кастомного пользователя
});

// --- Класс Сервиса Аутентификации ---
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Экземпляр Firestore

  // --- ИСПРАВЛЕННЫЙ ГЕТТЕР currentUser ---
  /// Асинхронно получает текущего пользователя приложения (из Firestore).
  /// Рекомендуется использовать authStateProvider для реактивного получения пользователя.
  Future<app.User?> get currentUser async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await _getUserData(firebaseUser.uid);
    }
    return null;
  }

  // --- Упрощенный геттер authStateChanges (теперь вызывает userStream) ---
  /// Стрим, который выдает нашего кастомного пользователя [app.User] или null.
  /// По сути, это то же самое, что и userStream().
  Stream<app.User?> get authStateChanges => userStream();

  /// Стрим, который выдает нашего кастомного пользователя [app.User] или null.
  Stream<app.User?> userStream() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      debugPrint(
        '[AuthService] AuthState изменился (userStream). Firebase User ID: ${firebaseUser?.uid}',
      );
      if (firebaseUser == null) {
        return null;
      }
      final appUser = await _getUserData(firebaseUser.uid);
      debugPrint(
        '[AuthService] Получен app_user (userStream): ${appUser?.id}, role: ${appUser?.role}',
      );
      return appUser;
    });
  }

  Future<app.User?> _getUserData(String uid) async {
    try {
      final DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(uid); // Используем экземпляр _firestore
      debugPrint('[AuthService] Пытаюсь получить документ: ${userDocRef.path}');
      final DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        debugPrint('[AuthService] Документ пользователя $uid существует.');
        final userData = userDoc.data() as Map<String, dynamic>;
        debugPrint('[AuthService] Данные пользователя $uid: $userData');

        // Добавляем ID документа, если он не является частью данных Firestore,
        // и если User.fromJson ожидает его.
        // Если ваша модель User уже имеет поле id, помеченное как
        // @JsonKey(includeFromJson: false, includeToJson: false),
        // то fromJson не будет его ожидать, и ID нужно будет добавить через copyWith после создания объекта.
        // Однако, если User.fromJson принимает Map и ожидает 'id' в этой карте, то это правильно:
        if (!userData.containsKey('id')) {
          // Добавляем, только если его нет
          userData['id'] = uid;
        }

        return app.User.fromJson(userData);
      } else {
        debugPrint(
          '[AuthService] ОШИБКА: Документ пользователя $uid НЕ НАЙДЕН в Firestore.',
        );
        return null;
      }
    } on FirebaseException catch (e, stackTrace) {
      // Добавляем stackTrace
      debugPrint(
        '[AuthService] ОШИБКА Firestore при получении данных пользователя $uid: ${e.code} - ${e.message}\n$stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      // Добавляем stackTrace
      debugPrint(
        '[AuthService] НЕИЗВЕСТНАЯ ОШИБКА при получении данных пользователя $uid: $e\n$stackTrace',
      );
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // try-catch без изменений
    try {
      debugPrint('[AuthService] Попытка входа для: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('[AuthService] Ошибка входа: $e'); // Лучше логировать ошибку
      throw Exception(
        'Failed to sign in: $e',
      ); // Пробрасываем как есть или кастомное исключение
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
    String lastName,
    String firstName,
    String? patronymic,
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
        final userData = {
          'lastName': lastName.trim(),
          'firstName': firstName.trim(),
          'patronymic': patronymic?.trim() ?? '',
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          // 'id': firebaseUser.uid, // Не нужно добавлять ID сюда, если он не является частью данных документа Firestore
          // и если fromJson его не ожидает напрямую (как мы обсуждали для _getUserData).
          // Если модель Group и User имеют @JsonKey(includeFromJson: false) для id,
          // то Firestore не будет пытаться записать это поле.
        };

        try {
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(userData); // Используем экземпляр _firestore
          debugPrint(
            '[AuthService] Данные пользователя ${firebaseUser.uid} сохранены в Firestore.',
          );
        } on FirebaseException catch (e, stackTrace) {
          // Добавляем stackTrace
          debugPrint(
            '[AuthService] ОШИБКА Firestore при сохранении данных пользователя ${firebaseUser.uid}: ${e.code} - ${e.message}\n$stackTrace',
          );
          // Здесь можно решить, что делать: удалить пользователя из Auth или оставить
        }
        return credential;
      } else {
        debugPrint(
          '[AuthService] ОШИБКА: credential.user == null после регистрации.',
        );
        return null;
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      // Добавляем stackTrace
      debugPrint(
        '[AuthService] ОШИБКА FirebaseAuth при регистрации: ${e.code} - ${e.message}\n$stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      // Добавляем stackTrace
      debugPrint(
        '[AuthService] НЕИЗВЕСТНАЯ ОШИБКА при регистрации: $e\n$stackTrace',
      );
      return null;
    }
  }

  Future<void> signOut() async {
    // try-catch без изменений
    try {
      debugPrint('[AuthService] Выход пользователя...');
      await _auth.signOut();
      debugPrint('[AuthService] Выход выполнен.');
    } catch (e, stackTrace) {
      // Добавляем stackTrace
      debugPrint('[AuthService] ОШИБКА при выходе: $e\n$stackTrace');
    }
  }
}
