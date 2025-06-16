// lib/core/fcm_service.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_navigation.dart';
import 'dart:convert';

// Провайдер для сервиса FCM
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(
    FirebaseMessaging.instance,
    FlutterLocalNotificationsPlugin(),
  );
});

class FCMService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  NotificationNavigation? _navigation;

  FCMService(this._messaging, this._localNotifications);

  // Установить навигацию
  void setNavigation(NotificationNavigation navigation) {
    _navigation = navigation;
  }

  // Инициализация FCM
  Future<void> initialize() async {
    try {
      // Запрашиваем разрешение на уведомления
      await _requestPermission();

      // Инициализируем локальные уведомления
      await _initializeLocalNotifications();

      // Настраиваем обработчики сообщений
      _setupMessageHandlers();

      // Получаем и сохраняем FCM токен
      await _handleTokenRefresh();

      // Подписываемся на обновления токена
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);

      debugPrint('FCM initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  // Запрос разрешений
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');
  }

  // Инициализация локальных уведомлений
  Future<void> _initializeLocalNotifications() async {
    // Создаем канал уведомлений для Android
    const androidChannel = AndroidNotificationChannel(
      'default_channel',
      'Основной канал',
      description: 'Канал для важных уведомлений',
      importance: Importance.high,
    );

    // Создаем канал
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Инициализируем локальные уведомления
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
  }

  // Настройка обработчиков сообщений
  void _setupMessageHandlers() {
    // Сообщения в foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Сообщения при открытии приложения из фона
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Фоновые сообщения
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Обработка сообщения при запуске приложения
    _handleInitialMessage();
  }

  // Обработка начального сообщения (при запуске приложения из уведомления)
  Future<void> _handleInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'Приложение запущено из уведомления: ${initialMessage.messageId}',
      );
      _handleMessageData(initialMessage.data);
    }
  }

  // Получение и сохранение токена
  Future<void> _handleTokenRefresh() async {
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _saveTokenToDatabase(token);
    }
  }

  // Сохранение токена в базу данных
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'fcmToken': token,
              'tokenUpdatedAt': FieldValue.serverTimestamp(),
            });
        debugPrint(
          'FCM Token сохранен в базе данных для пользователя ${user.uid}',
        );
      } else {
        debugPrint(
          'Не удалось сохранить FCM токен: пользователь не авторизован',
        );
      }
    } catch (e) {
      debugPrint('Ошибка сохранения FCM токена: $e');
    }
  }

  // Обработчик нажатия на уведомление
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Уведомление нажато: ${response.payload}');
    if (_navigation != null && response.payload != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        _navigation!.handleNotificationTap(data);
      } catch (e) {
        debugPrint('Ошибка обработки нажатия на уведомление: $e');
      }
    }
  }

  // Обработчик сообщения в foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Получено сообщение в foreground: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Показываем локальное уведомление
    await _showLocalNotification(message);
  }

  // Обработчик сообщения в background
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Получено сообщение в background: ${message.messageId}');
    _handleMessageData(message.data);
  }

  // Обработка данных сообщения
  void _handleMessageData(Map<String, dynamic> data) {
    if (_navigation != null && data.isNotEmpty) {
      _navigation!.handleNotificationTap(data);
    }
  }

  // Показать локальное уведомление
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Основной канал',
      channelDescription: 'Канал для важных уведомлений',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
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

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Новое уведомление',
      message.notification?.body ?? '',
      details,
      payload: json.encode(message.data),
    );
  }

  // Подписаться на тему
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Подписан на тему: $topic');
    } catch (e) {
      debugPrint('Ошибка подписки на тему $topic: $e');
    }
  }

  // Отписаться от темы
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Отписан от темы: $topic');
    } catch (e) {
      debugPrint('Ошибка отписки от темы $topic: $e');
    }
  }

  // Подписаться на темы в зависимости от роли пользователя
  Future<void> subscribeToUserTopics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;
      final groupId = userData['groupId'] as String?;

      // Подписываемся на общие темы
      await subscribeToTopic('announcements');

      // Подписываемся на темы по роли
      if (role != null) {
        await subscribeToTopic('role_$role');
      }

      // Подписываемся на темы группы (для студентов)
      if (groupId != null && role == 'student') {
        await subscribeToTopic('group_$groupId');
      }

      debugPrint('Подписка на темы завершена');
    } catch (e) {
      debugPrint('Ошибка подписки на темы пользователя: $e');
    }
  }
}

// Обработчик фоновых сообщений (должен быть вне класса)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Обработка фонового сообщения: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}
