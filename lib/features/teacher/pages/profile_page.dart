// lib/features/student/profile_page.dart (Исправленный)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/auth_service.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/routes/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// import 'edit_profile_page.dart';
// import '../settings/settings_screen.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    bool? confirmed = await showDialog<bool>(
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
                onPressed: () => Navigator.pop(ctx, true),
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
        // Используем ref для доступа к сервису и выхода
        await ref.read(authServiceProvider).signOut();
        // Навигация не нужна, GoRouter сделает редирект автоматически
        // при изменении authStateProvider
      } catch (e) {
        debugPrint("Sign out error: $e");
        if (context.mounted) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return authState.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Ошибка')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Ошибка загрузки профиля: $error'),
              ),
            ),
          ),
      data: (user) {
        // Если данные есть, но user == null (маловероятно из-за редиректа, но проверим)
        if (user == null) {
          return Scaffold(
            body: const Center(child: Text('Пользователь не найден.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Редактировать профиль',
                onPressed: () {
                  // Передаем текущий объект user в extra
                  // Используем AppRouter или GoRouter.of(context)
                  AppRouter.push(context, '/home/profile/edit', extra: user);
                  // или GoRouter.of(context).push('/home/profile/edit', extra: user);
                },
              ),
              // Можно добавить иконку настроек прямо в AppBar
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Настройки',
                onPressed: () {
                  AppRouter.push(context, '/settings');
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              // --- Секция Аватара и Имени ---
              Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colorScheme.secondaryContainer,
                    backgroundImage:
                        (user.photoURL != null && user.photoURL!.isNotEmpty)
                            ? NetworkImage(
                              user.photoURL!,
                            ) // Используем user.profilePicture
                            : const AssetImage(
                                  'assets/images/default_avatar.png',
                                )
                                as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // Используем getter fullName из модели User
                    user.fullName,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      user.email, // Используем поле 'email'
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Роль: ${user.role}', // Используем поле 'role'
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),

              // --- Секция Информации о Преподавателе ---
              if (user.role == 'teacher')
                Card(
                      child: Column(
                        children: [
                          // Личная информация
                          _buildInfoTile(
                            context,
                            icon: Icons.person_outline,
                            title: 'Фамилия',
                            value: user.lastName,
                          ),
                          _buildInfoTile(
                            context,
                            icon: Icons.person_outline,
                            title: 'Имя',
                            value: user.firstName,
                          ),
                          if (user.middleName != null &&
                              user.middleName!.isNotEmpty)
                            _buildInfoTile(
                              context,
                              icon: Icons.person_outline,
                              title: 'Отчество',
                              value: user.middleName!,
                            ),
                          if (user.dateOfBirth != null)
                            _buildInfoTile(
                              context,
                              icon: Icons.cake_outlined,
                              title: 'Дата рождения',
                              value:
                                  '${user.dateOfBirth!.day}.${user.dateOfBirth!.month}.${user.dateOfBirth!.year}',
                            ),
                          if (user.iin != null && user.iin!.isNotEmpty)
                            _buildInfoTile(
                              context,
                              icon: Icons.credit_card_outlined,
                              title: 'ИИН',
                              value: user.iin!,
                            ),
                          // Контактная информация
                          if (user.phone != null && user.phone!.isNotEmpty)
                            _buildInfoTile(
                              context,
                              icon: Icons.phone_outlined,
                              title: 'Телефон',
                              value: user.phone!,
                              isLast: true,
                            ),
                        ],
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1),
              const SizedBox(height: 16),

              // --- Системная информация ---
              Card(
                    child: Column(
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Icons.verified_user_outlined,
                          title: 'Статус аккаунта',
                          value: _getStatusDisplayName(user.status),
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons.fingerprint,
                          title: 'ID пользователя',
                          value: user.uid,
                          isLast: true,
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 16),

              // --- Кнопка Выхода ---
              Card(
                color: colorScheme.errorContainer.withAlpha(
                  77,
                ), // Примерно 30% прозрачности
                child: _buildInfoTile(
                  context,
                  icon: Icons.logout,
                  title: 'Выйти',
                  value: '',
                  iconColor: colorScheme.error,
                  titleColor: colorScheme.error,
                  isLast: true,
                  onTap: () => _signOut(context, ref),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ],
          ),
        );
      },
    );
  }

  // _buildInfoTile остается без изменений
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
    // Убрали dividerTheme, используем стандартный Divider

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: iconColor ?? colorScheme.primary, // Используем цвет из темы
            size: 24,
          ),
          title: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: titleColor,
            ), // Стиль M3
          ),
          trailing:
              value.isNotEmpty
                  ? Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      color:
                          colorScheme
                              .onSurfaceVariant, // Цвет для второстепенного текста
                    ),
                  )
                  : (onTap != null
                      ? const Icon(Icons.chevron_right)
                      : null), // Иконка ">" если есть onTap и нет value
          onTap: onTap,
          dense: false, // Используем стандартные отступы
          minVerticalPadding: 12, // Немного увеличим вертикальный отступ
        ),
        // Добавляем стандартный разделитель
        if (!isLast)
          const Divider(
            height: 1, // Стандартная высота
            thickness: 1, // Стандартная толщина
            indent:
                56, // Отступ слева (примерно ширина иконки + отступ ListTile)
            endIndent: 16, // Отступ справа
            // Цвет берется из DividerTheme темы Material 3
          ),
      ],
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Активный';
      case 'pending_approval':
        return 'Ожидает подтверждения';
      case 'rejected':
        return 'Отклонен';
      case 'suspended':
        return 'Заблокирован';
      default:
        return status;
    }
  }
}
