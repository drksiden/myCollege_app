// lib/features/auth/register_screen.dart (Исправленный)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/auth_service.dart';
import '../../routes/app_router.dart'; // Не используется напрямую, но может понадобиться

// Используем ConsumerStatefulWidget
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // --- ДОБАВЛЯЕМ РАЗДЕЛЬНЫЕ КОНТРОЛЛЕРЫ ДЛЯ ФИО ---
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController(); // Опционально
  // --- УБИРАЕМ _nameController ---
  // final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // --- НЕ ЗАБЫВАЕМ УДАЛИТЬ НОВЫЕ КОНТРОЛЛЕРЫ ---
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authService = ref.read(authServiceProvider);

    try {
      // Передаем значения из новых контроллеров
      final credential = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _lastNameController.text.trim(),
        _firstNameController.text.trim(),
        _patronymicController.text.trim(),
        'student',
      );

      if (credential == null && mounted) {
        setState(() {
          _errorMessage = 'Не удалось зарегистрироваться.';
        });
      }
      // Успешная регистрация обработается редиректом GoRouter
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapFirebaseAuthExceptionMessage(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Произошла неизвестная ошибка.';
        });
      }
      debugPrint('Неизвестная ошибка регистрации: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapFirebaseAuthExceptionMessage(String code) {
    // ... (код маппинга ошибок остается прежним) ...
    switch (code) {
      case 'weak-password':
        return 'Пароль слишком слабый.';
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует.';
      case 'invalid-email':
        return 'Некорректный формат email.';
      default:
        return 'Ошибка регистрации. Код: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Используем ConsumerWidget для доступа к ref, если нужно, но здесь пока не требуется
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- ОБНОВЛЕННЫЕ ПОЛЯ ДЛЯ ФИО ---
                TextFormField(
                  controller:
                      _lastNameController, // Используем новый контроллер
                  decoration: const InputDecoration(
                    labelText: 'Фамилия',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите фамилию';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller:
                      _firstNameController, // Используем новый контроллер
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller:
                      _patronymicController, // Используем новый контроллер
                  decoration: const InputDecoration(
                    labelText: 'Отчество (если есть)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  // Валидатор не нужен
                ),

                // --- КОНЕЦ ОБНОВЛЕННЫХ ПОЛЕЙ ФИО ---
                const SizedBox(height: 16), // Отступ перед Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    /* ... валидация email ... */
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
                    /* ... валидация пароля ... */
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Подтвердите пароль',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) {
                    /* ... валидация подтверждения пароля ... */
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, подтвердите пароль';
                    }
                    if (value != _passwordController.text) {
                      return 'Пароли не совпадают';
                    }
                    return null;
                  },
                ),

                // Убрали выбор роли DropdownButton (если он был)
                if (_errorMessage != null)
                  Padding(
                    /* ... отображение ошибки ... */
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
                  /* ... кнопка регистрации с индикатором ... */
                  onPressed: _isLoading ? null : _register,
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
                          : const Text('Зарегистрироваться'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  /* ... кнопка перехода на вход ... */
                  onPressed:
                      _isLoading
                          ? null
                          : () => AppRouter.go(
                            context,
                            '/login',
                          ), // Используем AppRouter если нужно
                  // onPressed: _isLoading ? null : () => GoRouter.of(context).go('/login'), // Или так
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
