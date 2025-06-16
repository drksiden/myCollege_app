// lib/routes/app_router.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Импорты экранов
import '../features/auth/loading_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/lock_screen.dart';
import '../features/admin/home_screen.dart';
import '../features/teacher/home_screen.dart';
import '../features/student/home_screen.dart';
import '../features/student/edit_profile_page.dart';
import '../features/student/attendance_page.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/pin/pin_setup_screen.dart';
import '../features/settings/pin/change_pin_screen.dart';
import '../features/student/schedule_page.dart';

// Импорты сервисов и моделей
import '../core/auth_service.dart';
import '../models/user.dart';
import '../widgets/approval_gate.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) {
      final location = state.uri.toString();
      final authState = ref.watch(authStateProvider);

      debugPrint('[GoRouter] Current location: $location');
      debugPrint('[GoRouter] Auth state loading: ${authState.isLoading}');
      debugPrint('[GoRouter] Auth state hasError: ${authState.hasError}');
      debugPrint('[GoRouter] Auth state hasValue: ${authState.hasValue}');

      // 1. Если состояние загружается, показываем loading
      if (authState.isLoading) {
        debugPrint('[GoRouter] Auth state loading, redirecting to /loading');
        return location == '/loading' ? null : '/loading';
      }

      // 2. Если ошибка загрузки authState
      if (authState.hasError) {
        debugPrint('[GoRouter] Auth state error: ${authState.error}');
        return location == '/login' ? null : '/login';
      }

      // 3. authState загружен
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthArea =
          location == '/login' ||
          location == '/register' ||
          location == '/loading';

      debugPrint('[GoRouter] User: ${user?.email}');
      debugPrint('[GoRouter] User status: ${user?.status}');
      debugPrint('[GoRouter] Is logged in: $isLoggedIn');
      debugPrint('[GoRouter] Is auth area: $isAuthArea');

      // 4. Если пользователь не вошел
      if (!isLoggedIn) {
        if (location == '/loading') {
          debugPrint('[GoRouter] No user, redirecting from loading to login');
          return '/login';
        }
        if (!isAuthArea) {
          debugPrint('[GoRouter] No user, redirecting to login');
          return '/login';
        }
        return null; // Остаемся в auth области
      }

      // 5. Пользователь вошел
      if (isLoggedIn) {
        // Если находимся в auth области или loading, перенаправляем в приложение
        if (isAuthArea) {
          debugPrint(
            '[GoRouter] User logged in, redirecting from auth area to /home',
          );
          return '/home';
        }

        // Проверяем статус пользователя для доступа к защищенным страницам
        if (user.status == 'pending_approval') {
          // Пользователь ожидает подтверждения - разрешаем доступ к /home
          // ApprovalGate покажет соответствующий экран
          if (location != '/home' && !location.startsWith('/home/')) {
            debugPrint(
              '[GoRouter] User pending approval, redirecting to /home',
            );
            return '/home';
          }
        } else if (user.status == 'rejected' || user.status == 'suspended') {
          // Пользователь отклонен/заблокирован - выход должен произойти в AuthService
          debugPrint(
            '[GoRouter] User rejected/suspended, redirecting to login',
          );
          return '/login';
        }
        // Для активных пользователей (status == 'active') разрешаем доступ везде
      }

      debugPrint('[GoRouter] No redirection needed');
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authStateProvider);

              if (authState.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (authState.hasError) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Ошибка: ${authState.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(authStateProvider),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final user = authState.valueOrNull;
              if (user == null) {
                return const Scaffold(
                  body: Center(child: Text('Пользователь не найден')),
                );
              }

              // Определяем, какой экран показать в зависимости от роли
              Widget homeScreen;
              switch (user.role) {
                case 'student':
                  homeScreen = const StudentHomeScreen();
                  break;
                case 'teacher':
                  homeScreen = const TeacherHomeScreen();
                  break;
                case 'admin':
                  homeScreen = const AdminHomeScreen();
                  break;
                default:
                  homeScreen = Scaffold(
                    body: Center(child: Text("Неизвестная роль: ${user.role}")),
                  );
              }

              // Оборачиваем в ApprovalGate для проверки статуса
              return ApprovalGate(child: homeScreen);
            },
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) {
              final user = state.extra as User?;
              if (user != null) {
                return EditProfilePage(initialUser: user);
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Ошибка: Не переданы данные пользователя для редактирования.',
                    ),
                  ),
                );
              }
            },
          ),
          GoRoute(
            path: 'attendance',
            builder: (context, state) => const AttendancePage(),
          ),
          GoRoute(
            path: 'schedule',
            builder: (context, state) => const StudentSchedulePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'pin/setup',
            builder: (context, state) => const PinSetupScreen(),
          ),
          GoRoute(
            path: 'pin/change',
            builder: (context, state) => const ChangePinScreen(),
          ),
        ],
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
    ],
  );
});

// Вспомогательные виджеты для разных статусов

Widget _buildPendingApprovalScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Ожидание подтверждения'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // Выход из аккаунта
          },
        ),
      ],
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Ожидание подтверждения',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ваша заявка на регистрацию отправлена администратору.\n\n'
              'Пожалуйста, ожидайте подтверждения. Вы получите уведомление, '
              'когда ваш аккаунт будет активирован.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Что происходит дальше?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Администратор проверит ваши данные\n'
                      '• Вы получите уведомление о решении\n'
                      '• После активации получите полный доступ',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRejectedScreen(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Доступ отклонен'),
      automaticallyImplyLeading: false,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Доступ отклонен',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'К сожалению, ваша заявка на регистрацию была отклонена.\n\n'
              'Пожалуйста, свяжитесь с администратором для получения '
              'дополнительной информации.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Утилитарный класс для навигации
class AppRouter {
  static void go(BuildContext context, String path, {Object? extra}) {
    try {
      GoRouter.of(context).go(path, extra: extra);
    } catch (e) {
      debugPrint('GoRouter Error (go): $e');
    }
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String path, {
    Object? extra,
  }) async {
    try {
      return await GoRouter.of(context).push<T>(path, extra: extra);
    } catch (e) {
      debugPrint('GoRouter Error (push): $e');
      return null;
    }
  }

  static void pop(BuildContext context) {
    try {
      if (GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      } else {
        debugPrint('GoRouter Warning: Cannot pop from current route');
      }
    } catch (e) {
      debugPrint('GoRouter Error (pop): $e');
    }
  }
}
