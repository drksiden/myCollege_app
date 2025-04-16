import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfileScreen extends StatefulWidget {
  // Получаем начальные данные пользователя для предзаполнения полей
  final Map<String, dynamic> initialUserData;

  const EditProfileScreen({super.key, required this.initialUserData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _patronymicController;
  late TextEditingController _phoneController;
  // Добавьте контроллеры для других РЕДАКТИРУЕМЫХ полей (если нужно)

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры начальными данными
    _lastNameController = TextEditingController(
      text: widget.initialUserData['lastName'] ?? '',
    );
    _firstNameController = TextEditingController(
      text: widget.initialUserData['firstName'] ?? '',
    );
    _patronymicController = TextEditingController(
      text: widget.initialUserData['patronymic'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialUserData['phone'] ?? '',
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Функция сохранения изменений
  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Выход если форма невалидна
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Ошибка: Пользователь не найден.";
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      return;
    }

    // Собираем обновленные данные
    final String newLastName = _lastNameController.text.trim();
    final String newFirstName = _firstNameController.text.trim();
    final String newPatronymic = _patronymicController.text.trim();
    final String newPhone = _phoneController.text.trim();

    // Формируем полное имя
    final String fullName = '$newLastName $newFirstName $newPatronymic'
        .trim()
        .replaceAll('  ', ' ');

    final Map<String, dynamic> updatedData = {
      'lastName': newLastName,
      'firstName': newFirstName,
      'patronymic': newPatronymic,
      'name': fullName, // Обновляем и полное имя
      'phone': newPhone,
      // Добавьте другие обновляемые поля сюда
    };

    try {
      // Обновляем документ в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedData); // Используем update, а не set

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Возвращаемся на предыдущий экран (Профиль)
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Не удалось обновить профиль.';
      });
      print("Profile update error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_errorMessage\n$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Убедимся, что индикатор сброшен, если виджет еще существует
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          // Кнопка сохранения изменений
          if (_isLoading)
            Padding(
              // Показываем индикатор в AppBar во время сохранения
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Сохранить изменения',
              onPressed: _saveProfile, // Вызываем сохранение
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  Text("Основная информация", style: textTheme.titleLarge),
                  const SizedBox(height: 20),

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
                  ),
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _patronymicController,
                    decoration: const InputDecoration(
                      labelText: "Отчество (если есть)",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    // Отчество опционально, валидатор не нужен
                  ),
                  const SizedBox(height: 24),
                  Text("Контактная информация", style: textTheme.titleLarge),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Телефон",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    // Можно добавить валидатор для формата телефона, если нужно
                  ),

                  // --- Не редактируемые поля (для информации) ---
                  const SizedBox(height: 24),
                  Text("Прочая информация", style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.email_outlined, size: 20),
                    title: Text(
                      "Email: ${widget.initialUserData['email'] ?? 'Не указан'}",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.badge_outlined, size: 20),
                    title: Text(
                      "Роль: ${widget.initialUserData['role'] ?? 'Не указана'}",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  if (widget.initialUserData['role'] == 'student') ...[
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.group_outlined, size: 20),
                      title: Text(
                        "Группа: ${widget.initialUserData['groupName'] ?? 'Не указана'}",
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.school_outlined, size: 20),
                      title: Text(
                        "Курс: ${widget.initialUserData['course'] ?? 'Не указан'}",
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.computer_outlined, size: 20),
                      title: Text(
                        "Специальность: ${widget.initialUserData['specialty'] ?? 'Не указана'}",
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],

                  // Можно добавить поле для загрузки фото профиля (сложнее)
                  // const SizedBox(height: 30),
                  // ElevatedButton.icon(
                  //    onPressed: _isLoading ? null : _saveProfile, // Блокируем во время загрузки
                  //    icon: const Icon(Icons.save),
                  //    label: const Text("СОХРАНИТЬ ИЗМЕНЕНИЯ"),
                  //    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  // ),
                ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1), // Анимация для полей
          ),
        ),
      ),
    );
  }
}
