// lib/main.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycollege/core/fcm_service.dart';
import 'package:mycollege/core/notification_navigation.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Константы для удобства ---
const _seedColor = Colors.indigo;
const _borderRadiusValue = 12.0;
const _buttonBorderRadiusValue = 8.0;
const _inputBorderRadiusValue = 8.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Инициализируем форматирование дат для русского языка
  await initializeDateFormatting('ru_RU', null);

  // Создаем контейнер Riverpod
  final container = ProviderContainer();
  final fcmService = container.read(fcmServiceProvider);
  await fcmService.initialize();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Инициализируем FCM после того, как виджет построен
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFCM();
    });
  }

  Future<void> _initializeFCM() async {
    try {
      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.initialize();

      // Устанавливаем навигацию после инициализации
      if (mounted) {
        final navigation = NotificationNavigation(context);
        fcmService.setNavigation(navigation);
      }
    } catch (e) {
      debugPrint('Ошибка инициализации FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeModeAsync = ref.watch(themeNotifierProvider);
    final currentThemeMode = themeModeAsync.valueOrSystem;

    // Остальной код остается прежним...
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    final commonBorderRadius = BorderRadius.circular(_borderRadiusValue);
    final buttonBorderRadius = BorderRadius.circular(_buttonBorderRadiusValue);
    final inputBorderRadius = BorderRadius.circular(_inputBorderRadiusValue);

    ThemeData configureBaseTheme(ColorScheme colorScheme) {
      return ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: inputBorderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: inputBorderRadius,
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withAlpha(128),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: inputBorderRadius,
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: inputBorderRadius,
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: inputBorderRadius,
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIconColor: colorScheme.onSurfaceVariant,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 24.0,
            ),
            shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Остальные настройки темы...
      );
    }

    final lightTheme = configureBaseTheme(lightColorScheme);
    final darkTheme = configureBaseTheme(darkColorScheme);

    return MaterialApp.router(
      routerConfig: router,
      title: 'myCollege App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: currentThemeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
    );
  }
}
