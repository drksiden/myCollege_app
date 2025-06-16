import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_navigation.dart';

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
    // Запрашиваем разрешение на уведомления
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

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
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Настраиваем обработчики сообщений
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Получаем FCM токен
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // Подписываемся на обновления токена
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM Token обновлен: $token');
      // TODO: Отправить новый токен на сервер
    });
  }

  // Обработчик нажатия на уведомление
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Уведомление нажато: ${response.payload}');
    if (_navigation != null && response.payload != null) {
      try {
        // Парсим данные из payload
        final data = Map<String, dynamic>.from(
          Map<String, dynamic>.from(response.payload as Map),
        );
        _navigation!.handleNotificationTap(data);
      } catch (e) {
        debugPrint('Ошибка обработки нажатия на уведомление: $e');
      }
    }
  }

  // Обработчик сообщения в foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Получено сообщение в foreground: ${message.messageId}');

    // Показываем локальное уведомление
    await _showLocalNotification(message);
  }

  // Обработчик сообщения в background
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Получено сообщение в background: ${message.messageId}');
    // TODO: Обработать сообщение в background
  }

  // Показать локальное уведомление
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Основной канал',
      channelDescription: 'Канал для важных уведомлений',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Новое уведомление',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  // Подписаться на тему
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Подписан на тему: $topic');
  }

  // Отписаться от темы
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Отписан от темы: $topic');
  }
}

// Обработчик фоновых сообщений (должен быть вне класса)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Обработка фонового сообщения: ${message.messageId}');
  // TODO: Обработать фоновое сообщение
}
