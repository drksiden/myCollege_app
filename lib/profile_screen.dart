import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для получения текущего пользователя и выхода
import 'package:cloud_firestore/cloud_firestore.dart'; // Для получения данных из Firestore
import 'package:flutter_application_1/edit_profile_screen.dart';

// import '../models/user_profile.dart'; // Модель можно использовать для типизации, но пока обойдемся Map
import '../settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Меняем на StatefulWidget
  const ProfileScreen({super.key}); // Делаем конструктор const

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Получаем текущего пользователя Auth

  // Функция выхода
  Future<void> _signOut(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      // Диалог подтверждения
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      ctx,
                      true,
                    ), // Возвращаем true при подтверждении
                child: Text(
                  'Выйти',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        // AuthWrapper автоматически перекинет на экран входа
      } catch (e) {
        print("Sign out error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка выхода: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar теперь строится внутри StreamBuilder, чтобы иметь доступ к snapshot.data
      // Убрали AppBar отсюда
      body:
          currentUser == null
              ? const Center(child: Text('Ошибка: Пользователь не найден'))
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  // Состояния загрузки, ошибки, отсутствия данных
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка загрузки данных: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('Данные профиля не найдены.'),
                    );
                  }

                  // Данные получены
                  final userData =
                      snapshot.data!
                          .data()!; // Используем ! т.к. проверили exists

                  // Строим Scaffold с AppBar ЗДЕСЬ
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Профиль'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Редактировать профиль',
                          onPressed: () {
                            // Переход на экран редактирования, передавая текущие данные
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditProfileScreen(
                                      initialUserData: userData,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    body:
                        currentUser == null
                            ? const Center(
                              child: Text('Ошибка: Пользователь не найден'),
                            ) // Если вдруг пользователь null
                            : StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>
                            >(
                              // Слушаем изменения документа текущего пользователя в коллекции 'users'
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser!.uid)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                // Состояние загрузки
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                // Ошибка загрузки данных
                                if (snapshot.hasError) {
                                  print("Firestore error: ${snapshot.error}");
                                  return Center(
                                    child: Text(
                                      'Ошибка загрузки данных профиля: ${snapshot.error}',
                                    ),
                                  );
                                }
                                // Данных нет (документ не найден)
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Center(
                                    child: Text('Данные профиля не найдены.'),
                                  );
                                }

                                // Данные получены!
                                final userData =
                                    snapshot.data!
                                        .data(); // Map<String, dynamic>
                                final userName =
                                    userData?['name'] ?? 'Имя не указано';
                                final userEmail =
                                    userData?['email'] ??
                                    currentUser!.email ??
                                    ''; // Берем из Firestore или из Auth
                                final userRole =
                                    userData?['role'] ?? 'неизвестно';
                                final userGroupName =
                                    userData?['groupName']; // Будет null, если не студент или нет группы
                                // ... получите другие поля таким же образом ...
                                final studentId = userData?['studentId'];
                                final age = userData?['age'];
                                final course = userData?['course'];
                                final specialty = userData?['specialty'];
                                final phone = userData?['phone'];

                                // Строим интерфейс на основе полученных данных
                                return ListView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 16.0,
                                  ),
                                  children: [
                                    // --- Секция Аватара ---
                                    Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 55,
                                              backgroundColor:
                                                  colorScheme
                                                      .secondaryContainer,
                                              // TODO: Загружать URL из userData['profileImageUrl']
                                              backgroundImage: const AssetImage(
                                                'assets/images/default_avatar.png',
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              userName,
                                              style: textTheme.headlineSmall,
                                              textAlign: TextAlign.center,
                                            ),
                                            if (userEmail.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  userEmail,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                ),
                                              ),
                                            Padding(
                                              // Показываем роль
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                'Роль: $userRole',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.secondary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .slideY(begin: 0.2),
                                    const SizedBox(height: 24),

                                    // --- Секция Информации ---
                                    Card(
                                          child: Column(
                                            children: [
                                              // Показываем поля в зависимости от роли и наличия данных
                                              if (studentId != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.badge_outlined,
                                                  title: 'Студент ID',
                                                  value: '$studentId',
                                                ),
                                              if (age != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.cake_outlined,
                                                  title: 'Возраст',
                                                  value: '$age лет',
                                                ),
                                              if (course != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.school_outlined,
                                                  title: 'Курс',
                                                  value: '$course курс',
                                                ),
                                              if (userGroupName != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.group_outlined,
                                                  title: 'Группа',
                                                  value: userGroupName,
                                                ), // Используем groupName
                                              if (specialty != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.computer_outlined,
                                                  title: 'Специальность',
                                                  value: '$specialty',
                                                ),
                                              if (phone != null)
                                                _buildInfoTile(
                                                  context,
                                                  icon: Icons.phone_outlined,
                                                  title: 'Телефон',
                                                  value: '$phone',
                                                  isLast: true,
                                                ),
                                              // Добавьте поля для учителя, если userRole == 'teacher'
                                              // if (userRole == 'teacher' && teacherSubject != null) ...
                                            ],
                                          ),
                                        )
                                        .animate(delay: 200.ms)
                                        .fadeIn(duration: 400.ms)
                                        .slideX(begin: -0.1),
                                    const SizedBox(height: 16),

                                    // --- Настройки ---
                                    Card(
                                          child: _buildInfoTile(
                                            context,
                                            icon: Icons.settings_outlined,
                                            title: 'Настройки',
                                            value: '',
                                            isLast: true,
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const SettingsScreen(),
                                                  ),
                                                ),
                                          ),
                                        )
                                        .animate(delay: 300.ms)
                                        .fadeIn(duration: 400.ms),
                                    const SizedBox(height: 16),

                                    // --- Выход ---
                                    Card(
                                          child: _buildInfoTile(
                                            context,
                                            icon: Icons.logout,
                                            title: 'Выйти',
                                            value: '',
                                            iconColor: colorScheme.error,
                                            titleColor: colorScheme.error,
                                            isLast: true,
                                            onTap:
                                                () => _signOut(
                                                  context,
                                                ), // Вызываем функцию выхода
                                          ),
                                        )
                                        .animate(delay: 400.ms)
                                        .fadeIn(duration: 400.ms),
                                  ],
                                );
                              },
                            ),
                  );
                },
              ),
    );
  }

  // _buildInfoTile остается как был в предыдущем ответе
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    Color? titleColor,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dividerTheme =
        Theme.of(context).dividerTheme; // Получаем стиль разделителя

    return Column(
      mainAxisSize: MainAxisSize.min, // Чтобы Column не занимал лишнее место
      children: [
        ListTile(
          // Используем стандартные отступы ListTileTheme
          // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Icon(
            icon,
            color:
                iconColor ??
                colorScheme.primary, // Цвет иконки (по умолч. primary)
            size: 24, // Стандартный размер
          ),
          title: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              // Стиль заголовка
              color: titleColor,
            ),
          ),
          trailing:
              value.isNotEmpty
                  ? Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ) // Стиль значения
                  : null,
          onTap: onTap,
          dense: false, // Убираем плотность
          // Уменьшаем вертикальный отступ для более плотного вида без dense
          minVerticalPadding: 10,
        ),
        // Добавляем разделитель, используя цвет из темы
        if (!isLast)
          Divider(
            height: dividerTheme.space ?? 1, // Используем высоту из темы
            thickness: dividerTheme.thickness ?? 0.5, // Толщина из темы
            color: dividerTheme.color, // Цвет из темы
            indent: 56, // Отступ слева (примерно ширина иконки + отступ)
            endIndent: 16, // Отступ справа
          ),
      ],
    );
  }
}
