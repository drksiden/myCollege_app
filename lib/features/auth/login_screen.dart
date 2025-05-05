// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для FirebaseAuthException
import '../../core/auth_service.dart'; // Импорт провайдера authServiceProvider
import '../../routes/app_router.dart'; // Импорт AppRouter для навигации

// Используем ConsumerStatefulWidget для доступа к ref
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Ключ для валидации формы
  bool _isLoading = false; // Состояние для индикатора загрузки
  String? _errorMessage; // Сообщение об ошибке для отображения

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Проверяем валидность формы
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Не продолжаем, если форма не валидна
    }

    setState(() {
      _isLoading = true; // Показываем индикатор загрузки
      _errorMessage = null; // Сбрасываем предыдущую ошибку
    });

    // Получаем сервис аутентификации через ref.read (т.к. нам не нужно слушать изменения сервиса здесь)
    final authService = ref.read(authServiceProvider);

    try {
      final credential = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Проверка результата (хотя редирект обычно управляется authStateProvider)
      if (credential == null && mounted) {
        // Эта ветка может не понадобиться, если AuthService всегда бросает исключение при ошибке
        setState(() {
          _errorMessage = 'Не удалось войти. Попробуйте снова.';
        });
      }
      // Если вход успешен, authStateProvider изменится, и GoRouter сам перенаправит
      // на /home благодаря redirect в app_router.dart. Дополнительная навигация здесь не нужна.
    } on FirebaseAuthException catch (e) {
      // Обрабатываем известные ошибки FirebaseAuth
      if (mounted) {
        setState(() {
          _errorMessage = _mapFirebaseAuthExceptionMessage(e.code);
        });
      }
    } catch (e) {
      // Обрабатываем прочие ошибки
      if (mounted) {
        setState(() {
          _errorMessage = 'Произошла неизвестная ошибка.';
        });
        debugPrint('Неизвестная ошибка входа: $e');
      }
    } finally {
      // Убираем индикатор загрузки в любом случае
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Вспомогательная функция для перевода кодов ошибок Firebase
  String _mapFirebaseAuthExceptionMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'invalid-email':
        return 'Некорректный формат email.';
      case 'user-disabled':
        return 'Учетная запись пользователя отключена.';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Попробуйте позже.';
      // Добавьте другие коды по мере необходимости
      default:
        return 'Ошибка входа. Код: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в myCollege')),
      body: Center(
        // Центрируем содержимое
        child: SingleChildScrollView(
          // Позволяет скроллить на маленьких экранах
          padding: const EdgeInsets.all(24.0),
          child: Form(
            // Оборачиваем в Form для валидации
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Растягиваем элементы по ширине
              children: [
                // Можно добавить логотип
                // Image.asset('assets/images/logo.png', height: 80),
                // const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                // Отображение сообщения об ошибке
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
                // Кнопка входа с индикатором загрузки
                ElevatedButton(
                  // Выключаем кнопку во время загрузки
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
                  // Переход на экран регистрации
                  onPressed:
                      _isLoading
                          ? null
                          : () => AppRouter.go(context, '/register'),
                  child: const Text('Нет аккаунта? Зарегистрироваться'),
                ),
                // Можно добавить кнопку "Забыли пароль?"
                // TextButton(
                //   onPressed: _isLoading ? null : () { /* TODO: Implement password reset */ },
                //   child: const Text('Забыли пароль?'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
