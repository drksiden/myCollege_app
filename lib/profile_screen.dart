import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Для анимаций
import '../models/user_profile.dart'; // Импорт модели
import '../mock_data.dart'; // Импорт mock данных

class ProfileScreen extends StatelessWidget {
  // Получаем профиль (пока из mock данных)
  final UserProfile userProfile = mockUserProfile;

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          // Добавляем кнопку редактирования (пока без функции)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip:
                'Редактировать профиль', // Подсказка при наведении/удержании
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
      // Используем ListView вместо SingleChildScrollView + Column для лучшей структуры
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Секция Аватара и Имени ---
          Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        Colors.grey.shade300, // Фон для placeholder'а
                    backgroundImage:
                        userProfile.profileImageUrl.isNotEmpty
                            ? NetworkImage(userProfile.profileImageUrl)
                            : const AssetImage(
                                  'assets/images/default_avatar.png',
                                )
                                as ImageProvider,
                    // Можно добавить границу
                    // child: CircleAvatar(radius: 58, backgroundColor: Theme.of(context).scaffoldBackgroundColor), // Пример границы
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (userProfile
                      .email
                      .isNotEmpty) // Показываем email, если он есть
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        userProfile.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2), // Анимация для блока аватара

          const SizedBox(height: 24), // Увеличенный отступ
          // --- Секция Основной Информации ---
          Card(
                // Используем стиль карты из темы
                elevation: 1, // Немного уменьшим тень для информации
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ), // Внутренние отступы карты
                  child: Column(
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
                      if (userProfile
                          .phone
                          .isNotEmpty) // Показываем телефон, если есть
                        _buildInfoTile(
                          context,
                          icon: Icons.phone_outlined,
                          title: 'Телефон',
                          value: userProfile.phone,
                          isLast:
                              true, // Убираем разделитель для последнего элемента
                        ),
                    ],
                  ),
                ),
              )
              // Анимация для карточки с информацией
              .animate(delay: 200.ms) // Появляется чуть позже аватара
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1), // Выезжает сбоку

          const SizedBox(height: 24),

          // --- Секция Действий ---
          Card(
                elevation: 1,
                child: _buildInfoTile(
                  context,
                  icon: Icons.logout,
                  title: 'Выйти',
                  value: '', // Нет значения для действия
                  iconColor: colorScheme.error, // Красный цвет для выхода
                  titleColor: colorScheme.error,
                  isLast: true, // Нет разделителя
                  onTap: () {
                    // TODO: Реализовать логику выхода
                    showDialog(
                      // Пример диалога подтверждения
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Подтверждение'),
                            content: const Text(
                              'Вы уверены, что хотите выйти?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx); // Закрыть диалог
                                  // Здесь будет реальная логика выхода
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Выход из системы... (демо)',
                                      ),
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
              )
              .animate(delay: 400.ms) // Появляется еще позже
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  // Переделанный хелпер для создания ListTile
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor, // Цвет иконки (опционально)
    Color? titleColor, // Цвет заголовка (опционально)
    bool isLast = false, // Является ли последним элементом в группе
    VoidCallback? onTap, // Обработчик нажатия (опционально)
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: iconColor ?? colorScheme.primary,
          ), // Иконка слева
          title: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500, // Немного жирнее
              color: titleColor, // Применяем цвет, если задан
            ),
          ),
          // Отображаем значение справа, если оно не пустое
          trailing:
              value.isNotEmpty ? Text(value, style: textTheme.bodyLarge) : null,
          onTap: onTap, // Устанавливаем обработчик нажатия
          dense: true, // Делаем ListTile немного компактнее
        ),
        // Добавляем разделитель после каждого элемента, кроме последнего
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(
              left: 56.0,
              right: 16.0,
            ), // Отступ слева как у текста ListTile
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade300,
            ),
          ),
      ],
    );
  }
}
