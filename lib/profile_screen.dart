import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../mock_data.dart';
import '../settings_screen.dart'; // Импорт экрана настроек

class ProfileScreen extends StatelessWidget {
  // Получаем профиль (пока из mock данных)
  final UserProfile userProfile = mockUserProfile;

  // Убираем const из конструктора, т.к. userProfile не константа
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем тему для доступа к стилям и цветам
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cardTheme =
        Theme.of(context).cardTheme; // Получаем стиль карт из темы

    return Scaffold(
      // AppBar использует стиль из темы (прозрачный, без тени)
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать профиль',
            onPressed: () {
              // TODO: Реализовать переход на экран редактирования профиля
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция редактирования в разработке'),
                ),
              );
            },
          ),
        ],
      ),
      // Используем ListView для прокрутки контента
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ), // Отступы для всего контента
        children: [
          // --- Секция Аватара и Имени ---
          Column(
            children: [
              CircleAvatar(
                radius: 55, // Немного уменьшим радиус
                backgroundColor:
                    colorScheme
                        .secondaryContainer, // Фон из темы для placeholder'а
                backgroundImage:
                    userProfile.profileImageUrl.isNotEmpty
                        ? NetworkImage(userProfile.profileImageUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                userProfile.name,
                style: textTheme.headlineSmall, // Используем стиль темы
                textAlign: TextAlign.center,
              ),
              if (userProfile.email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    userProfile.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ), // Цвет из темы
                  ),
                ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2), // Анимация

          const SizedBox(height: 24),

          // --- Секция Основной Информации ---
          // Используем Card со стилем из темы (без тени, с границей)
          Card(
                // elevation: cardTheme.elevation, // Берется из темы
                // shape: cardTheme.shape, // Берется из темы
                // color: cardTheme.color, // Берется из темы
                // margin: cardTheme.margin, // Задаем через ListView.padding
                child: Column(
                  // Убрали лишний Padding, т.к. ListTile имеет свой
                  children: [
                    _buildInfoTile(
                      context,
                      icon: Icons.badge_outlined,
                      title: 'Студент ID',
                      value: userProfile.studentId,
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.cake_outlined,
                      title: 'Возраст',
                      value: '${userProfile.age} лет',
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Курс',
                      value: '${userProfile.course} курс',
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.group_outlined,
                      title: 'Группа',
                      value: userProfile.group,
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.computer_outlined,
                      title: 'Специальность',
                      value: userProfile.specialty,
                    ),
                    if (userProfile.phone.isNotEmpty)
                      _buildInfoTile(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Телефон',
                        value: userProfile.phone,
                        isLast: true, // Убираем разделитель
                      ),
                  ],
                ),
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1), // Анимация

          const SizedBox(height: 16), // Уменьшим отступ
          // --- Секция Настроек ---
          Card(
            // Отдельная карта для настроек
            child: _buildInfoTile(
              context,
              icon: Icons.settings_outlined, // Иконка настроек
              title: 'Настройки',
              value: '', // Нет значения
              isLast: true, // Последний элемент в этой карте
              onTap: () {
                // Переход на экран настроек
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms), // Анимация

          const SizedBox(height: 16),

          // --- Секция Выхода ---
          Card(
            // Отдельная карта для выхода
            child: _buildInfoTile(
              context,
              icon: Icons.logout,
              title: 'Выйти',
              value: '',
              iconColor: colorScheme.error, // Цвет иконки выхода
              titleColor: colorScheme.error, // Цвет текста выхода
              isLast: true, // Последний элемент
              onTap: () {
                // TODO: Реализовать логику выхода
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Подтверждение'),
                        content: const Text('Вы уверены, что хотите выйти?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Выход из системы... (демо)'),
                                ),
                              );
                            },
                            child: Text(
                              'Выйти',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms), // Анимация
        ],
      ),
    );
  }

  // Обновленный хелпер для создания ListTile в стиле темы
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
