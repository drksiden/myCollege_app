import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для сервиса уведомлений
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FirebaseFirestore.instance);
});

class NotificationService {
  final FirebaseFirestore _firestore;
  final _logger = Logger();

  NotificationService(this._firestore);

  // Отправка уведомления конкретному пользователю
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Получаем FCM токен пользователя
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        _logger.w('FCM токен не найден для пользователя $userId');
        return;
      }

      // Отправляем уведомление через Cloud Functions
      await _firestore.collection('notifications').add({
        'token': fcmToken,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Ошибка отправки уведомления пользователю', error: e);
      rethrow;
    }
  }

  // Отправка уведомления по теме
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Отправляем уведомление через Cloud Functions
      await _firestore.collection('notifications').add({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Ошибка отправки уведомления по теме', error: e);
      rethrow;
    }
  }

  // Отправка уведомления пользователям с определенной ролью
  Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Отправляем уведомление через Cloud Functions
      await _firestore.collection('notifications').add({
        'role': role,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Ошибка отправки уведомления по роли', error: e);
      rethrow;
    }
  }

  // Сохранение FCM токена пользователя
  Future<void> saveUserFCMToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Ошибка сохранения FCM токена', error: e);
      rethrow;
    }
  }

  // Подписка на тему
  Future<void> subscribeToTopic({
    required String userId,
    required String topic,
  }) async {
    try {
      await _firestore.collection('user_topics').add({
        'userId': userId,
        'topic': topic,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Ошибка подписки на тему', error: e);
      rethrow;
    }
  }

  // Отписка от темы
  Future<void> unsubscribeFromTopic({
    required String userId,
    required String topic,
  }) async {
    try {
      final query =
          await _firestore
              .collection('user_topics')
              .where('userId', isEqualTo: userId)
              .where('topic', isEqualTo: topic)
              .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      _logger.e('Ошибка отписки от темы', error: e);
      rethrow;
    }
  }
}
