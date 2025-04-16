// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для получения пользователя
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Для проверки ПИН/Био флагов
import 'package:shared_preferences/shared_preferences.dart'; // Для флага "предложение показано"
import 'dart:async'; // Для Duration
import 'package:flutter/services.dart'; // Для WidgetsBindingObserver
import 'auth/lock_screen.dart'; // Импорт экрана блокировки
import 'auth/pin_setup_screen.dart'; // Импорт экрана настройки ПИН

// Экраны вкладок
import 'schedule_screen.dart';
import 'grades_screen.dart';
import 'performance_screen.dart';
import 'activities_screen.dart';
import 'profile_screen.dart';

// ---------------------------------------------------------
// Вспомогательный виджет для сохранения состояния вкладок в PageView
// ---------------------------------------------------------
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Важно вызвать super.build
    return widget.child;
  }

  // Возвращаем true, чтобы сохранить состояние
  @override
  bool get wantKeepAlive => true;
}
// ---------------------------------------------------------

// ---------------------------------------------------------
// Основной экран с вкладками и управлением блокировкой
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Добавляем 'with WidgetsBindingObserver' для отслеживания состояния приложения
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0; // Индекс выбранной вкладки
  late PageController _pageController; // Контроллер для PageView
  final _storage =
      const FlutterSecureStorage(); // Доступ к безопасному хранилищу

  // Флаг, показывается ли экран блокировки в данный момент
  bool _isLockScreenVisible = false;

  // --- Переменные для тайм-аута блокировки ---
  DateTime? _pausedTime; // Время, когда приложение было свернуто
  final Duration _lockTimeout = const Duration(
    minutes: 1,
  ); // Таймаут блокировки
  // --- Время последней успешной разблокировки (для защиты от зацикливания) ---
  DateTime? _lastUnlockTime;
  // -----------------------------------------------------------------------

  // Список виджетов для каждой вкладки, обернутых в KeepAliveWrapper
  final List<Widget> _screens = [
    const KeepAliveWrapper(child: ScheduleScreen()),
    const KeepAliveWrapper(child: GradesScreen()),
    const KeepAliveWrapper(child: PerformanceScreen()),
    const KeepAliveWrapper(child: ActivitiesScreen()),
    KeepAliveWrapper(
      child: ProfileScreen(),
    ), // ProfileScreen может быть Stateful
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    // Регистрируем наблюдатель за жизненным циклом приложения
    WidgetsBinding.instance.addObserver(this);
    // После отрисовки первого кадра проверяем, нужно ли предложить настройку
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptQuickLoginSetup();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Обязательно удаляем наблюдатель при уничтожении виджета
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Логика проверки и предложения настройки ПИН/Биометрии при первом входе ---
  Future<void> _checkAndPromptQuickLoginSetup() async {
    final user = FirebaseAuth.instance.currentUser;
    // Если виджет уже не активен или пользователя нет, выходим
    if (!mounted || user == null) return;

    try {
      final userId = user.uid;
      // Ключи для SecureStorage и SharedPreferences
      final pinEnabledKey = 'pin_enabled_$userId';
      final bioEnabledKey = 'bio_enabled_$userId';
      final promptShownKey = 'quick_login_prompt_shown_$userId';

      // Читаем флаги из безопасного хранилища
      final pinEnabled = await _storage.read(key: pinEnabledKey) == 'true';
      final bioEnabled = await _storage.read(key: bioEnabledKey) == 'true';

      // Читаем флаг из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final promptShown = prefs.getBool(promptShownKey) ?? false;

      // Показываем диалог, только если:
      // 1) Ни ПИН, ни Биометрия не включены
      // 2) Предложение еще не показывалось
      // 3) Виджет все еще активен (mounted)
      if (!pinEnabled && !bioEnabled && !promptShown && mounted) {
        bool? setupAgreed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Быстрый вход"),
                content: const Text(
                  "Хотите настроить вход по ПИН-коду или биометрии для быстрого и безопасного доступа?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Позже"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Настроить"),
                  ),
                ],
              ),
        );

        // Запоминаем, что предложение показали (даже если отказались)
        await prefs.setBool(promptShownKey, true);

        // Если согласились и виджет еще активен, переходим к настройке ПИН
        if (setupAgreed == true && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PinSetupScreen()),
          );
        }
      }
    } catch (e) {
      print("Error checking/prompting quick login setup: $e");
      // Можно показать SnackBar об ошибке чтения настроек, но это не критично
    }
  }
  // --------------------------------------------------------------------

  // --- Отслеживание состояния приложения (для блокировки) ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print("App Lifecycle State: $state");
    if (state == AppLifecycleState.paused) {
      // Приложение свернуто - запоминаем время, ТОЛЬКО если экран блокировки НЕ показан
      if (!_isLockScreenVisible) {
        _pausedTime = DateTime.now();
        // print("App Paused at: $_pausedTime");
      } else {
        // print("App Paused, but lock screen is visible. Ignoring pause time update.");
      }
    } else if (state == AppLifecycleState.resumed) {
      // Приложение возобновилось
      final resumeTime = DateTime.now();
      // print("App Resumed at: $resumeTime");

      // Защита от быстрого повторного вызова сразу после успешной разблокировки
      if (_lastUnlockTime != null &&
          resumeTime.difference(_lastUnlockTime!) <
              const Duration(seconds: 1)) {
        print("Ignoring resume event shortly after unlock.");
        _pausedTime = null; // Сбрасываем паузу на всякий случай
        return;
      }

      bool requireLockDueToTimeout = false;
      // Проверяем, было ли приложение свернуто и вышло ли время
      if (_pausedTime != null) {
        final durationInBackground = resumeTime.difference(_pausedTime!);
        if (durationInBackground >= _lockTimeout) {
          requireLockDueToTimeout = true; // Таймаут превышен
          print("Lock timeout exceeded. Lock screen required.");
        }
        _pausedTime = null; // Сбрасываем время паузы после проверки
      } else {
        print(
          "App Resumed (no pause time recorded or first launch). No timeout lock needed.",
        );
      }

      // Показываем экран блокировки ТОЛЬКО если превышен таймаут
      if (requireLockDueToTimeout) {
        _showLockScreen();
      } else {
        print("No lock required on this resume based on timeout.");
        // Примечание: Если нужно показывать блокировку при ЛЮБОМ возобновлении
        // (а не только по таймауту), вызовите _showLockScreen() здесь БЕЗ условия.
        // Например, так (но тогда описание про таймаут выше неверно):
        // _showLockScreen();
      }
    }
  }
  // ----------------------------------------------------

  // --- Показ экрана блокировки ---
  Future<void> _showLockScreen() async {
    // Предотвращаем повторный показ, если он уже идет или пользователь не вошел
    if (_isLockScreenVisible ||
        FirebaseAuth.instance.currentUser == null ||
        !mounted) {
      // print("Skipping _showLockScreen: visible=$_isLockScreenVisible, userNull=${FirebaseAuth.instance.currentUser == null}, mounted=$mounted");
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    // Проверяем, включен ли хотя бы один метод быстрого входа
    final pinEnabled =
        await _storage.read(key: 'pin_enabled_$userId') == 'true';
    final bioEnabled =
        await _storage.read(key: 'bio_enabled_$userId') == 'true';

    // Показываем, только если что-то включено
    if ((pinEnabled || bioEnabled) && mounted) {
      print("Showing lock screen...");
      // Ставим флаг ПЕРЕД показом экрана
      setState(() {
        _isLockScreenVisible = true;
      });

      // Показываем LockScreen модально
      bool? unlocked = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => const LockScreen(),
          fullscreenDialog: true,
        ),
      );

      print("Lock screen popped. Unlocked: $unlocked");

      // Если разблокировка прошла успешно, записываем время
      if (unlocked == true) {
        _lastUnlockTime = DateTime.now();
      }

      // Сбрасываем флаг видимости ПОСЛЕ обработки результата
      if (mounted) {
        setState(() {
          _isLockScreenVisible = false;
        });
      }

      // Если пользователь не разблокировал (нажал Выйти на LockScreen)
      if (unlocked != true) {
        print("User did not unlock via LockScreen. Signing out.");
        await FirebaseAuth.instance.signOut(); // Выходим из Firebase
        // AuthWrapper перенаправит на экран входа
      } else {
        print("Screen unlocked successfully via LockScreen.");
      }
    } else {
      print("Lock screen skipped (PIN/Bio disabled).");
    }
  }
  // -------------------------------

  // Обработчик нажатия на элемент нижней навигации
  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Обработчик смены страницы через PageView (свайпом)
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Сборка UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView для отображения вкладок и свайпа между ними
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Обновляет _selectedIndex при свайпе
        children: _screens, // Список экранов с KeepAliveWrapper
      ),
      // Нижняя панель навигации
      bottomNavigationBar: BottomNavigationBar(
        // Стили берутся из BottomNavigationBarThemeData в main.dart
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Переключает страницу при нажатии
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Пары',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Оценки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Успев.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Активности',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
