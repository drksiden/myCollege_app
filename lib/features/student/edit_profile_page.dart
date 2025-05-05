// lib/features/student/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide User; // Скрываем User из auth
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart'; // Для context.pop()

import '../../models/user.dart'; // Наша модель User

// Используем ConsumerStatefulWidget для контроллеров и состояния загрузки
class EditProfilePage extends ConsumerStatefulWidget {
  // Получаем начальные данные пользователя через конструктор
  final User initialUser;

  const EditProfilePage({super.key, required this.initialUser});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Контроллеры для редактируемых полей
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _patronymicController;
  late TextEditingController _phoneController;
  // Добавь другие контроллеры, если нужно

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры начальными данными из widget.initialUser
    _lastNameController = TextEditingController(
      text: widget.initialUser.lastName,
    );
    _firstNameController = TextEditingController(
      text: widget.initialUser.firstName,
    );
    _patronymicController = TextEditingController(
      text: widget.initialUser.patronymic ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialUser.phone ?? '',
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

  // --- Функция сохранения изменений ---
  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Получаем UID текущего пользователя (лучше из FirebaseAuth)
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Ошибка: Пользователь не найден.";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final updatedLastName = _lastNameController.text.trim();
    final updatedFirstName = _firstNameController.text.trim();
    final updatedPatronymic = _patronymicController.text.trim();

    // Собираем только обновляемые поля
    final Map<String, dynamic> updatedData = {
      'lastName': updatedLastName,
      'firstName': updatedFirstName,
      'patronymic':
          updatedPatronymic.isEmpty
              ? null
              : updatedPatronymic, // Сохраняем null, если поле пустое
      'phone':
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(), // Обновляем время изменения
      // ВАЖНО: НЕ обновляем email, role, groupId, course и т.д. здесь,
      // если это не предусмотрено логикой редактирования профиля пользователя!
      // Обновляем `name` (если оно используется где-то еще, хотя лучше использовать getter `fullName`)
      'name':
          '$updatedLastName $updatedFirstName ${updatedPatronymic.isEmpty ? '' : updatedPatronymic}'
              .trim()
              .replaceAll('  ', ' '),
    };

    try {
      // Обновляем документ в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен!'),
            backgroundColor: Colors.green,
          ),
        );
        // Используем GoRouter для возврата назад
        context.pop(); // Закрываем текущий экран
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Не удалось обновить профиль.';
      });
      debugPrint("Profile update error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_errorMessage\n$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          // Кнопка сохранения или индикатор
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Сохранить изменения',
              onPressed: _saveProfile,
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
              // --- Редактируемые поля ---
              Text(
                "Личные данные",
                style: textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Фамилия"),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Введите фамилию'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "Имя"),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Введите имя'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patronymicController,
                decoration: const InputDecoration(
                  labelText: "Отчество (если есть)",
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Телефон",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // --- Не редактируемые поля (для информации) ---
              Text(
                "Информация об обучении",
                style: textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.email_outlined, size: 20),
                title: Text(
                  "Email: ${widget.initialUser.email}",
                ), // Не редактируется
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined, size: 20),
                title: Text(
                  "Роль: ${widget.initialUser.role}",
                ), // Не редактируется
                dense: true,
              ),
              if (widget.initialUser.role == 'student') ...[
                ListTile(
                  leading: const Icon(Icons.group_outlined, size: 20),
                  title: Text(
                    "Группа: ${widget.initialUser.groupName ?? 'Не указана'}",
                  ),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.school_outlined, size: 20),
                  title: Text(
                    "Курс: ${widget.initialUser.course ?? 'Не указан'}",
                  ),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.computer_outlined, size: 20),
                  title: Text(
                    "Специальность: ${widget.initialUser.specialty ?? 'Не указана'}",
                  ),
                  dense: true,
                ),
              ],
              // Кнопку сохранения можно разместить в AppBar (как сделано) или внизу формы
            ].animate(interval: 80.ms).fadeIn(duration: 250.ms).slideX(begin: 0.1),
          ),
        ),
      ),
    );
  }
}
