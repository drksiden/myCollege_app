import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/admin/home_screen.dart';
import 'package:flutter_application_1/features/auth/loading_screen.dart';
import 'package:flutter_application_1/features/auth/lock_screen.dart';
import 'package:flutter_application_1/features/settings/pin/change_pin_screen.dart';
import 'package:flutter_application_1/features/settings/pin/pin_setup_screen.dart';
import 'package:flutter_application_1/features/settings/settings_screen.dart';
import 'package:flutter_application_1/features/student/edit_profile_page.dart';
import 'package:flutter_application_1/features/teacher/home_screen.dart'; // Исправлено "teather" на "teacher"
import 'package:flutter_application_1/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/student/home_screen.dart';
import '../core/auth_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) {
      final location = state.uri.toString(); // Куда пытаемся перейти

      // --- НОВАЯ ЛОГИКА РЕДИРЕКТА ---

      // 1. Если authState еще грузится И мы находимся на /loading, остаемся там.
      if (authState.isLoading && location == '/loading') {
        debugPrint(
          '[GoRouter Redirect] Auth state loading, staying on /loading',
        );
        return null; // Остаемся на /loading
      }

      // 2. Если authState загрузился, но с ошибкой (можно показать экран ошибки?)
      if (authState.hasError && location != '/login') {
        debugPrint(
          '[GoRouter Redirect] Auth state error, redirecting to /login',
        );
        // Можно перенаправить на логин или на спец. экран ошибки
        return '/login';
      }

      // 3. Определяем, вошел ли пользователь (после загрузки/ошибки)
      final isLoggedIn = authState.valueOrNull != null;

      // 4. Определяем, пытается ли пользователь попасть на страницы входа/регистрации/загрузки
      final isLoggingArea =
          location == '/login' ||
          location == '/register' ||
          location == '/loading';

      debugPrint(
        '[GoRouter Redirect] Current location: $location, isLoggedIn: $isLoggedIn, isLoggingArea: $isLoggingArea',
      );

      // 5. Если пользователь НЕ вошел И пытается попасть НЕ в зону входа -> на /login
      if (!isLoggedIn && !isLoggingArea) {
        debugPrint(
          '[GoRouter Redirect] Redirecting to /login (not logged in, not in logging area)',
        );
        return '/login';
      }

      // 6. Если пользователь ВОШЕЛ И пытается попасть В зону входа -> на /home
      if (isLoggedIn && isLoggingArea) {
        debugPrint(
          '[GoRouter Redirect] Redirecting to /home (logged in, tried logging area)',
        );
        return '/home';
      }

      // 7. Во всех остальных случаях (вошел и идет куда можно, не вошел и идет на /login) - разрешаем
      debugPrint('[GoRouter Redirect] No redirection needed.');
      return null;
      // ---------------------------
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder:
            (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder:
            (BuildContext context, GoRouterState state) =>
                const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          final user = authState.valueOrNull;
          if (user != null) {
            switch (user.role) {
              // Используем switch для ясности
              case 'student':
                return const StudentHomeScreen(); // <-- Указываем наш новый экран
              case 'teacher':
                return const TeacherHomeScreen();
              case 'admin':
                return const AdminHomeScreen();
              default:
                return Scaffold(
                  body: Center(child: Text("Неизвестная роль: ${user.role}")),
                );
            }
          }
          // Если пользователь еще загружается или null (хотя редирект должен сработать)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'profile/edit', // Путь будет /home/profile/edit
            builder: (BuildContext context, GoRouterState state) {
              // Получаем объект User, переданный из ProfilePage
              final user = state.extra as User?;
              if (user != null) {
                return EditProfilePage(initialUser: user);
              } else {
                // Если данные не переданы, можно показать ошибку или вернуться назад
                // Возможно, лучше редиректить на /home или /profile
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
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'pin/setup', // Относительный путь -> /settings/pin/setup
            builder: (context, state) => PinSetupScreen(),
          ),
          GoRoute(
            path: 'pin/change', // Относительный путь -> /settings/pin/change
            builder: (context, state) => ChangePinScreen(),
          ),
        ],
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
    ],
  );
});

class AppRouter {
  // --- Метод go() остается ---
  static void go(BuildContext context, String path, {Object? extra}) {
    // Используем GoRouter.of(context) для доступа к роутеру из текущего контекста
    try {
      GoRouter.of(context).go(path, extra: extra);
    } catch (e) {
      debugPrint(
        'GoRouter Error (go): $e. Context might not contain GoRouter.',
      );
      // Возможно, стоит показать SnackBar или залогировать ошибку серьезнее
    }
  }

  // --- ДОБАВЛЯЕМ МЕТОД push() ---
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String path, {
    Object? extra,
  }) async {
    // Добавляем async и возвращаемый тип Future<T?>
    try {
      // Возвращаем Future, который возвращает GoRouter.push<T>()
      return await GoRouter.of(context).push<T>(path, extra: extra);
    } catch (e) {
      debugPrint(
        'GoRouter Error (push): $e. Context might not contain GoRouter.',
      );
      return null; // Возвращаем null в случае ошибки
    }
  }

  // --- ДОБАВЛЯЕМ МЕТОД pop() ---
  static void pop(BuildContext context) {
    try {
      // Проверяем, можно ли вернуться назад
      if (GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      } else {
        debugPrint(
          'GoRouter Warning (pop): Cannot pop from the current route.',
        );
      }
    } catch (e) {
      debugPrint(
        'GoRouter Error (pop): $e. Context might not contain GoRouter.',
      );
    }
  }
}
