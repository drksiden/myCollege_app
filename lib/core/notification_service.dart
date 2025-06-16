import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для сервиса уведомлений
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    FirebaseFirestore.instance,
    FirebaseMessaging.instance,
  );
});

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  NotificationService(this._firestore, this._messaging);

  // Отправить уведомление конкретному пользователю
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Получаем FCM токен пользователя из Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) {
        throw Exception('FCM токен пользователя не найден');
      }

      // Отправляем уведомление через Cloud Functions
      await _firestore.collection('notifications').add({
        'token': fcmToken,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка отправки уведомления: $e');
      rethrow;
    }
  }

  // Отправить уведомление всем пользователям с определенной ролью
  Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Получаем всех пользователей с указанной ролью
      final usersSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: role)
              .get();

      // Отправляем уведомление каждому пользователю
      for (var userDoc in usersSnapshot.docs) {
        final fcmToken = userDoc.data()['fcmToken'];
        if (fcmToken != null) {
          await _firestore.collection('notifications').add({
            'token': fcmToken,
            'title': title,
            'body': body,
            'data': data ?? {},
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Ошибка отправки уведомлений по роли: $e');
      rethrow;
    }
  }

  // Отправить уведомление всем подписчикам темы
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка отправки уведомления по теме: $e');
      rethrow;
    }
  }
}
