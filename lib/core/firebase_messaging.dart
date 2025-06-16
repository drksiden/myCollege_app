import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'notification_service.dart';

// Глобальный ключ для навигации
final navigatorKey = GlobalKey<NavigatorState>();

final firebaseMessagingProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService(
    FirebaseMessaging.instance,
    ref.watch(notificationServiceProvider),
  );
});

class FirebaseMessagingService {
  final FirebaseMessaging _messaging;
  final NotificationService _notificationService;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _logger = Logger();
  late final GoRouter _router;

  FirebaseMessagingService(this._messaging, this._notificationService) {
    _router = GoRouter.of(navigatorKey.currentContext!);
  }

  Future<void> initialize() async {
    // Инициализация локальных уведомлений
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Запрашиваем разрешение на уведомления
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Получаем FCM токен
    final token = await _messaging.getToken();
    if (token != null) {
      // Сохраняем токен в Firestore для текущего пользователя
      final currentUser = _messaging.app.options.projectId;
      if (currentUser != null) {
        await _notificationService.saveUserFCMToken(
          userId: currentUser,
          fcmToken: token,
        );
      }
    }

    // Обработка уведомлений в фоновом режиме
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Обработка уведомлений в активном режиме
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Обработка нажатия на уведомление
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Обработчик фоновых уведомлений
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // В фоновом режиме уведомление показывается автоматически системой
    _logger.i('Получено фоновое уведомление: ${message.messageId}');
  }

  // Обработчик уведомлений в активном режиме
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Показываем локальное уведомление
    await _showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'Новое уведомление',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  // Обработчик нажатия на уведомление
  void _handleMessageOpenedApp(RemoteMessage message) {
    _navigateToScreen(message.data);
  }

  // Обработчик нажатия на локальное уведомление
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateToScreen(
        Map<String, dynamic>.from(
          Map<String, dynamic>.from(response.payload as Map),
        ),
      );
    }
  }

  // Показать локальное уведомление
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Основной канал',
      channelDescription: 'Канал для основных уведомлений',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // Навигация к нужному экрану
  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'message':
        final chatId = data['chatId'];
        if (chatId != null) {
          _router.push('/chat/$chatId');
        }
        break;
      case 'grade':
        final subjectId = data['subjectId'];
        if (subjectId != null) {
          _router.push('/grades/$subjectId');
        }
        break;
      case 'homework':
        final taskId = data['taskId'];
        if (taskId != null) {
          _router.push('/homework/$taskId');
        }
        break;
      case 'schedule_update':
        _router.push('/schedule');
        break;
      case 'announcement':
        final announcementId = data['announcementId'];
        if (announcementId != null) {
          _router.push('/announcements/$announcementId');
        }
        break;
    }
  }

  // Подписка на тему
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Отписка от темы
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
