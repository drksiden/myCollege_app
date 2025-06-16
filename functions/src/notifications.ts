import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const processNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const messaging = admin.messaging();

    try {
      // Отправка уведомления конкретному пользователю
      if (notification.token) {
        await messaging.send({
          token: notification.token,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data || {},
        });
      }

      // Отправка уведомления по теме
      if (notification.topic) {
        await messaging.send({
          topic: notification.topic,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data || {},
        });
      }

      // Отправка уведомления по роли
      if (notification.role) {
        const usersSnapshot = await admin
          .firestore()
          .collection('users')
          .where('role', '==', notification.role)
          .get();

        const tokens: string[] = [];
        usersSnapshot.forEach((doc) => {
          const fcmToken = doc.data().fcmToken;
          if (fcmToken) {
            tokens.push(fcmToken);
          }
        });

        if (tokens.length > 0) {
          await messaging.sendMulticast({
            tokens,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: notification.data || {},
          });
        }
      }

      // Удаляем обработанное уведомление
      await snap.ref.delete();
    } catch (error) {
      console.error('Error processing notification:', error);
      throw error;
    }
  });

// Функция для подписки на тему
export const subscribeToTopic = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Требуется авторизация'
    );
  }

  const { topic } = data;
  if (!topic) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Тема не указана'
    );
  }

  try {
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();

    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) {
      throw new functions.https.HttpsError(
        'not-found',
        'FCM токен не найден'
      );
    }

    await admin.messaging().subscribeToTopic(fcmToken, topic);
    return { success: true };
  } catch (error) {
    console.error('Error subscribing to topic:', error);
    throw new functions.https.HttpsError('internal', 'Ошибка подписки на тему');
  }
});

// Функция для отписки от темы
export const unsubscribeFromTopic = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Требуется авторизация'
      );
    }

    const { topic } = data;
    if (!topic) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Тема не указана'
      );
    }

    try {
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        throw new functions.https.HttpsError(
          'not-found',
          'FCM токен не найден'
        );
      }

      await admin.messaging().unsubscribeFromTopic(fcmToken, topic);
      return { success: true };
    } catch (error) {
      console.error('Error unsubscribing from topic:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Ошибка отписки от темы'
      );
    }
  }
); 