const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Функция для отправки уведомлений
exports.sendNotification = functions.firestore
    .document('notifications/{notificationId}')
    .onCreate(async (snap, context) => {
        const notification = snap.data();

        // Если уведомление для конкретного устройства
        if (notification.token) {
            const message = {
                token: notification.token,
                notification: {
                    title: notification.title,
                    body: notification.body,
                },
                data: notification.data || {},
            };

            try {
                await admin.messaging().send(message);
                console.log('Уведомление успешно отправлено');
            } catch (error) {
                console.error('Ошибка отправки уведомления:', error);
            }
        }
        // Если уведомление для темы
        else if (notification.topic) {
            const message = {
                topic: notification.topic,
                notification: {
                    title: notification.title,
                    body: notification.body,
                },
                data: notification.data || {},
            };

            try {
                await admin.messaging().send(message);
                console.log('Уведомление успешно отправлено в тему');
            } catch (error) {
                console.error('Ошибка отправки уведомления в тему:', error);
            }
        }
    }); 