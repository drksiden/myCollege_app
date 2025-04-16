import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback
  onToggleView; // Функция для вызова переключения в AuthenticationScreen

  const LoginScreen({super.key, required this.onToggleView});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Успех - AuthWrapper перенаправит
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Неверный email или пароль.';
      } else if (e.code == 'invalid-email') {
        message = 'Неверный формат email.';
      } else {
        message = 'Произошла ошибка входа. Попробуйте снова.';
        // print('Login error: ${e.code} - ${e.message}'); // Убрали print
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      // Проверяем mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Произошла неизвестная ошибка.';
      });
      // print('Unknown login error: $e'); // Убрали print
      // Проверяем mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        // Используем SafeArea
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Иконка/Лого
                  Icon(
                        Icons.school_outlined, // Замените на ваше лого/иконку
                        size: 70, // Немного меньше
                        color: colorScheme.primary,
                      )
                      .animate()
                      .fade(delay: 200.ms, duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 20),

                  // 2. Заголовки
                  Text(
                        "С возвращением!",
                        style:
                            textTheme
                                .headlineMedium, // Убрал жирность, т.к. стиль уже может быть жирным
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fade(delay: 300.ms)
                      .slideY(begin: 0.5, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    "Войдите в свой аккаунт",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 400.ms),
                  const SizedBox(height: 40),

                  // 3. Поле Email
                  TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          // Стиль из InputDecoratorTheme в main.dart
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.alternate_email_outlined,
                          ), // Иконка
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                (value == null ||
                                        value.isEmpty ||
                                        !value.contains('@'))
                                    ? 'Введите корректный email'
                                    : null,
                      )
                      .animate()
                      .fade(delay: 500.ms)
                      .slideX(begin: -0.5, duration: 400.ms),
                  const SizedBox(height: 16),

                  // 4. Поле Пароль
                  TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: "Пароль",
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator:
                            (value) =>
                                (value == null || value.length < 6)
                                    ? 'Пароль не менее 6 символов'
                                    : null,
                      )
                      .animate()
                      .fade(delay: 600.ms)
                      .slideX(begin: 0.5, duration: 400.ms),
                  const SizedBox(height: 30),

                  // 5. Кнопка Войти или Индикатор загрузки
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _isLoading
                            ? Center(
                              key: const ValueKey('loader'),
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            )
                            : ElevatedButton(
                              key: const ValueKey('loginButton'),
                              onPressed: _signIn,
                              // Стиль из ElevatedButtonThemeData в main.dart
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                "ВОЙТИ",
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                  ).animate().fade(delay: 700.ms),
                  const SizedBox(height: 24),

                  // 6. Переключатель на Регистрацию
                  TextButton(
                    onPressed:
                        widget
                            .onToggleView, // Используем колбэк для переключения
                    child: Text(
                      "Нет аккаунта? Зарегистрироваться",
                      style:
                          textTheme
                              .bodyMedium, // Стиль по умолчанию для TextButton из темы
                    ),
                  ).animate().fade(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
