import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart'; // Если будете использовать Provider для данных пользователя

import 'home_screen.dart';
import 'auth/authentication_screen.dart'; // Экран входа/регистрации (создадим ниже)

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Слушаем изменения состояния аутентификации
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Показываем индикатор загрузки во время проверки
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Если пользователь вошел (есть данные)
        if (snapshot.hasData && snapshot.data != null) {
          // Здесь можно было бы получить данные пользователя из Firestore через Provider
          // и передать их в HomeScreen, если нужно
          // final userProvider = Provider.of<UserProvider>(context);
          // userProvider.loadUser(snapshot.data!); // Пример
          return const HomeScreen(); // Показываем главный экран
        }

        // Если пользователь не вошел
        return const AuthenticationScreen(); // Показываем экран входа/регистрации
      },
    );
  }
}
