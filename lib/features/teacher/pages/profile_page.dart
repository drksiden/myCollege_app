// lib/features/teacher/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Для анимаций

import '../../../core/auth_service.dart'; // Для authStateProvider
import '../../../models/user.dart' as app_user; // Используем псевдоним
import '../../../routes/app_router.dart'; // Для навигации AppRouter.push
import '../providers/journal_providers.dart'; // Для teacherSubjectsAndGroupsProvider и GroupInfo

// Общий виджет для отображения информации (можно вынести в common/widgets)
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

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(icon, color: iconColor ?? colorScheme.primary, size: 24),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        trailing:
            value.isNotEmpty
                ? Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
                : (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        dense: false,
        minVerticalPadding: 12,
      ),
      if (!isLast)
        const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16),
    ],
  );
}

class TeacherProfilePage extends ConsumerWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Данные о группах и предметах учителя
    final teacherGroupsAndSubjectsAsync = ref.watch(
      teacherSubjectsAndGroupsProvider,
    );

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Ошибка загрузки профиля: $error'),
            ),
          ),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Пользователь не найден.'));
        }

        return Scaffold(
          // Scaffold здесь не нужен, если это часть PageView в TeacherHomeScreen
          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            children: [
              // --- Секция Аватара и Имени ---
              Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colorScheme.secondaryContainer,
                    backgroundImage:
                        (user.profilePicture != null &&
                                user.profilePicture!.isNotEmpty)
                            ? NetworkImage(user.profilePicture!)
                            : const AssetImage(
                                  'assets/images/default_avatar.png',
                                )
                                as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      user.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Роль: ${user.role}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),

              // --- Редактирование профиля ---
              Card(
                child: _buildInfoTile(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Редактировать профиль',
                  value: '', // Пустое значение, чтобы показать chevron
                  onTap: () {
                    AppRouter.push(context, '/home/profile/edit', extra: user);
                  },
                  isLast: true, // Если это единственный элемент в этой карточке
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // --- Секция "Мои группы и предметы" ---
              Text(
                "Преподаваемые дисциплины",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              teacherGroupsAndSubjectsAsync
                  .when(
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    error:
                        (err, st) => Card(
                          color: colorScheme.errorContainer.withAlpha(77),
                          child: ListTile(
                            title: Text(
                              'Ошибка загрузки групп: $err',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                    data: (groupsInfoList) {
                      if (groupsInfoList.isEmpty) {
                        return const Card(
                          child: ListTile(
                            title: Text(
                              'Вы не назначены ни на одну группу или предмет.',
                            ),
                          ),
                        );
                      }
                      return Card(
                        child: Column(
                          children:
                              groupsInfoList.map((groupInfo) {
                                return ExpansionTile(
                                  // Используем ExpansionTile для групп
                                  key: ValueKey(
                                    groupInfo.id,
                                  ), // Ключ для сохранения состояния
                                  leading: Icon(
                                    Icons.group_work_outlined,
                                    color: colorScheme.secondary,
                                  ),
                                  title: Text(
                                    groupInfo.name,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  childrenPadding: const EdgeInsets.only(
                                    left: 24,
                                    bottom: 8,
                                    right: 16,
                                  ),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children:
                                      groupInfo.subjects
                                          .map(
                                            (subject) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.book_outlined,
                                                    size: 18,
                                                    color: colorScheme.tertiary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      subject,
                                                      style:
                                                          textTheme.bodyMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                );
                              }).toList(),
                        ),
                      );
                    },
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),

              // Кнопки "Настройки" и "Выход" будут в AppBar TeacherHomeScreen
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
