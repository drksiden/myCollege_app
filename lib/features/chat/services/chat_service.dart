import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/notification_manager.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(
    FirebaseFirestore.instance,
    ref.watch(notificationManagerProvider),
  );
});

class ChatService {
  final FirebaseFirestore _firestore;
  final NotificationManager _notificationManager;

  ChatService(this._firestore, this._notificationManager);

  Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String message,
  }) async {
    try {
      // Получаем информацию об отправителе
      final senderDoc =
          await _firestore.collection('users').doc(senderId).get();
      final senderName = senderDoc.data()?['displayName'] ?? 'Пользователь';

      // Сохраняем сообщение
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'recipientId': recipientId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Отправляем уведомление
      await _notificationManager.notifyNewMessage(
        recipientId: recipientId,
        senderName: senderName,
        messagePreview:
            message.length > 50 ? '${message.substring(0, 50)}...' : message,
      );
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
      rethrow;
    }
  }
}
