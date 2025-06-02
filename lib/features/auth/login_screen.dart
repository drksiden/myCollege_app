// lib/features/auth/login_screen.dart (ИСПРАВЛЕННЫЙ И ОБНОВЛЕННЫЙ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// --- ДОБАВЛЕНО ---: Импорт для работы с Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes/app_router.dart';

// Используем ConsumerStatefulWidget, так как в будущем может понадобиться ref
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- ИЗМЕНЕНО ---: Полностью переписана логика входа
  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ШАГ 1: Аутентификация пользователя через Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) {
        // Маловероятно, но для надежности
        throw Exception('Ошибка входа. Попробуйте снова.');
      }

      // ШАГ 2: Получение документа пользователя из Firestore для проверки статуса
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) {
        // Неконсистентность данных: пользователь есть в Auth, но нет в Firestore
        await FirebaseAuth.instance
            .signOut(); // Выходим из системы для безопасности
        throw Exception(
          'Профиль пользователя не найден. Обратитесь к администратору.',
        );
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final String status = userData?['status'] ?? 'inactive';

      // ШАГ 3: Проверка статуса пользователя
      if (status == 'active') {
        // СТАТУС АКТИВЕН: Все в порядке.
        // authStateProvider обработает изменение состояния и GoRouter выполнит редирект.
        // Ничего больше делать не нужно.
      } else {
        // СТАТУС НЕ АКТИВЕН: Вход запрещен.
        // КРИТИЧЕСКИ ВАЖНО: сначала выходим из системы, чтобы authStateProvider не сработал.
        await FirebaseAuth.instance.signOut();

        String message;
        switch (status) {
          case 'pending_approval':
            message = 'Ваша заявка ожидает одобрения администратором.';
            break;
          case 'suspended':
            message = 'Ваша учетная запись заблокирована.';
            break;
          default:
            message = 'Вход невозможен. Ваша учетная запись неактивна.';
        }

        if (mounted) {
          setState(() {
            _errorMessage = message;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapFirebaseAuthExceptionMessage(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst(
            'Exception: ',
            '',
          ); // Показываем чистое сообщение об ошибке
        });
        debugPrint('Неизвестная ошибка входа: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapFirebaseAuthExceptionMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS': // Новый код ошибки для неверного email/пароля
        return 'Неверный email или пароль.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'invalid-email':
        return 'Некорректный формат email.';
      case 'user-disabled':
        return 'Учетная запись пользователя отключена.';
      default:
        return 'Ошибка входа. Попробуйте позже.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Структура виджета остается без изменений
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в myCollege')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Войти'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () => AppRouter.go(context, '/register'),
                  child: const Text('Нет аккаунта? Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
