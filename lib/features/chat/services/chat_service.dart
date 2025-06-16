import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/notification_manager.dart';
import 'package:logger/logger.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(
    FirebaseFirestore.instance,
    ref.watch(notificationManagerProvider),
  );
});

class ChatService {
  final FirebaseFirestore _firestore;
  final NotificationManager _notificationManager;
  final _logger = Logger();

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

      // Создаем или получаем существующий чат
      final chatQuery =
          await _firestore
              .collection('chats')
              .where(
                'participantIds',
                arrayContainsAny: [senderId, recipientId],
              )
              .get();

      String chatId;
      if (chatQuery.docs.isEmpty) {
        // Создаем новый чат
        final newChatRef = await _firestore.collection('chats').add({
          'participantIds': [senderId, recipientId],
          'lastMessage': message,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': senderId,
          'unreadCount': {recipientId: 1},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        chatId = newChatRef.id;
      } else {
        // Используем существующий чат
        chatId = chatQuery.docs.first.id;
        // Обновляем информацию о чате
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': senderId,
          'unreadCount.$recipientId': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Сохраняем сообщение
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'recipientId': recipientId,
        'chatId': chatId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Отправляем уведомление
      await _notificationManager.notifyNewMessage(
        recipientId: recipientId,
        senderId: senderId,
        senderName: senderName,
        messagePreview:
            message.length > 50 ? '${message.substring(0, 50)}...' : message,
        chatId: chatId,
      );
    } catch (e) {
      _logger.e('Ошибка отправки сообщения', error: e);
      rethrow;
    }
  }
}
