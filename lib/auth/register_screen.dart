import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum UserRole { student, teacher }

class RegisterScreen extends StatefulWidget {
  final VoidCallback
  onToggleView; // Функция для вызова переключения в AuthenticationScreen
  const RegisterScreen({super.key, required this.onToggleView});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Раздельные контроллеры для ФИО
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController(); // Опционально
  final _groupCodeController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Исправлено: Добавлены скобки
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    DocumentSnapshot? groupDoc;
    if (_selectedRole == UserRole.student) {
      // Сделаем код группы обязательным для студента
      if (_groupCodeController.text.trim().isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Студенту необходимо ввести код группы.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      try {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('groups')
                .where('code', isEqualTo: _groupCodeController.text.trim())
                .limit(1)
                .get();

        if (querySnapshot.docs.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Группа с таким кодом не найдена.';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_errorMessage!),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        groupDoc = querySnapshot.docs.first;
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка проверки кода группы.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Убран print
        return;
      }
    }

    // --- Регистрация пользователя ---
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        // Исправлено: Явно указан тип Map
        final Map<String, dynamic> userData = {
          'uid': uid,
          'email': _emailController.text.trim(),
          // Сохраняем ФИО раздельно и/или слитно
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'patronymic':
              _patronymicController.text
                  .trim(), // Будет пустым, если поле не используется
          'name':
              '${_lastNameController.text.trim()} ${_firstNameController.text.trim()} ${_patronymicController.text.trim()}'
                  .trim()
                  .replaceAll('  ', ' '), // Полное имя для отображения
          'role': _selectedRole.name,
          'createdAt': Timestamp.now(),
          if (_selectedRole == UserRole.student && groupDoc != null) ...{
            'groupId': groupDoc.id,
            'groupName': groupDoc.get('name') ?? '',
            'course': groupDoc.get('course') ?? 0,
            'specialty': groupDoc.get('specialty') ?? '',
          } else if (_selectedRole == UserRole.teacher) ...{
            // Добавьте поля для учителя при необходимости
          },
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userData);
      }
      // Успех - AuthWrapper перенаправит
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          _errorMessage = 'Пароль слишком слабый.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'Аккаунт с таким email уже существует.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Неверный формат email.';
        } else {
          _errorMessage = 'Произошла ошибка регистрации.';
        }
        // Убран print
      });
      // Исправлено: Проверка mounted
      if (mounted && _errorMessage != null) {
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
      // Убран print
      // Исправлено: Проверка mounted
      if (mounted && _errorMessage != null) {
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
    // final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Убираем AppBar
      body: SafeArea(
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
                  // 1. Заголовок
                  Text(
                    "Создание аккаунта",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.5),
                  const SizedBox(height: 24),

                  // 2. Выбор Роли
                  SegmentedButton<UserRole>(
                    segments: const <ButtonSegment<UserRole>>[
                      ButtonSegment<UserRole>(
                        value: UserRole.student,
                        label: Text('Студент'),
                        icon: Icon(Icons.school_outlined),
                      ),
                      ButtonSegment<UserRole>(
                        value: UserRole.teacher,
                        label: Text('Учитель'),
                        icon: Icon(Icons.person_outline),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (Set<UserRole> newSelection) {
                      setState(() {
                        _selectedRole = newSelection.first;
                      });
                    },
                    // Можно добавить стиль из темы
                    // style: ...,
                  ).animate().fade(delay: 300.ms),
                  const SizedBox(height: 24),

                  // 3. Поля ФИО
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Фамилия",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Введите фамилию'
                                : null,
                  ).animate().fade(delay: 400.ms).slideX(begin: -0.5),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: "Имя",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Введите имя'
                                : null,
                  ).animate().fade(delay: 450.ms).slideX(begin: 0.5),
                  const SizedBox(height: 16),
                  TextFormField(
                    // Опциональное поле Отчество
                    controller: _patronymicController,
                    decoration: const InputDecoration(
                      labelText: "Отчество (если есть)",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    // Валидатор не нужен, т.к. поле опционально
                  ).animate().fade(delay: 500.ms).slideX(begin: -0.5),
                  // const SizedBox(height: 16), // Убрали отступ, т.к. поле кода ниже анимировано

                  // 4. Поле кода группы (только для студентов)
                  AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation) => SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ), // Fade + Size
                        child:
                            _selectedRole == UserRole.student
                                ? Padding(
                                  // Добавим Padding для отступа
                                  key: const ValueKey('groupCodeField'),
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: TextFormField(
                                    controller: _groupCodeController,
                                    decoration: const InputDecoration(
                                      labelText: "Код группы",
                                      prefixIcon: Icon(
                                        Icons.group_work_outlined,
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            _selectedRole == UserRole.student &&
                                                    (value == null ||
                                                        value.isEmpty)
                                                ? 'Введите код группы'
                                                : null,
                                  ),
                                )
                                : const SizedBox.shrink(
                                  key: ValueKey('noGroupCodeField'),
                                ),
                      )
                      .animate(key: ValueKey('anim_${_selectedRole.name}'))
                      .fade(delay: 550.ms), // Анимация для блока целиком
                  const SizedBox(height: 16),

                  // 5. Поля Email и Пароль
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.alternate_email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@'))
                                ? 'Введите корректный email'
                                : null,
                  ).animate().fade(delay: 600.ms).slideX(begin: 0.5),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Пароль (мин. 6 симв.)",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            (value == null || value.length < 6)
                                ? 'Пароль не менее 6 символов'
                                : null,
                  ).animate().fade(delay: 650.ms).slideX(begin: -0.5),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Подтвердите пароль",
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            (value != _passwordController.text)
                                ? 'Пароли не совпадают'
                                : null,
                  ).animate().fade(delay: 700.ms).slideX(begin: 0.5),
                  const SizedBox(height: 30),

                  // 6. Кнопка и Переключатель
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _isLoading
                            ? const Center(
                              key: ValueKey('loaderReg'),
                              child: CircularProgressIndicator(),
                            )
                            : ElevatedButton(
                              key: const ValueKey('registerButton'),
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                "ЗАРЕГИСТРИРОВАТЬСЯ",
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                  ).animate().fade(delay: 750.ms),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: widget.onToggleView, // Используем колбэк
                    child: const Text("Уже есть аккаунт? Войти"),
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
