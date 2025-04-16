// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для SystemChrome и SystemUiOverlayStyle
import 'package:flutter_application_1/auth_wrapper.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:provider/provider.dart'; // Импорт provider
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/theme_notifier.dart'; // Импорт нашего Notifier'а

Future<void> main() async {
  // 1. Гарантируем инициализацию биндингов Flutter ДО любых await или плагинов
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем локализацию для дат (русский язык)
  await initializeDateFormatting('ru', null);

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Используем сгенерированные опции
  );

  // 3. Запускаем приложение с Provider'ом для управления темой
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Создаем и предоставляем ThemeNotifier
      child: const MyStudentApp(),
    ),
  );
}

class MyStudentApp extends StatelessWidget {
  const MyStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Следим за изменениями в ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    // Определяем, активна ли темная тема (учитывая системные настройки)
    final isCurrentlyDark = themeNotifier.isDarkMode(context);

    // Устанавливаем стиль системных панелей (статус-бар, нав-бар)
    // Делаем это здесь, чтобы стиль реагировал на смену темы
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Статус-бар (сверху)
        statusBarColor: Colors.transparent, // Прозрачный фон
        statusBarIconBrightness:
            isCurrentlyDark ? Brightness.light : Brightness.dark, // Иконки
        // Навигационная панель (снизу)
        // Используем цвет фона, подходящий для M3 тем
        systemNavigationBarColor:
            isCurrentlyDark
                ? const Color(0xFF1F1F1F) // Примерный темный фон для панели
                : const Color(0xFFF8F8F8), // Примерный светлый фон для панели
        systemNavigationBarDividerColor: Colors.transparent, // Без разделителя
        systemNavigationBarIconBrightness:
            isCurrentlyDark ? Brightness.light : Brightness.dark, // Иконки
      ),
    );

    // --- Определяем Светлую Тему ---
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Основная цветовая схема (можно поэкспериментировать с seedColor)
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2), // Пример: более спокойный синий
        brightness: Brightness.light,
        // Можно переопределить конкретные цвета схемы
        surface: const Color(0xFFFDFDFD), // Чуть отличный от белого фон
        surfaceContainerHighest: const Color(
          0xFFF0F0F0,
        ), // Цвет фона "карточек"
      ),
      fontFamily:
          'Inter', // Пример современного шрифта (нужно добавить в проект)
      // Стили компонентов для минимализма
      scaffoldBackgroundColor: const Color(0xFFFDFDFD), // Фон Scaffold
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0, // Без тени
        backgroundColor: Colors.transparent, // Прозрачный AppBar
        foregroundColor:
            Colors.black87, // Цвет иконок и текста на AppBar (для светлой темы)
        // Стиль системных оверлеев уже задан глобально через SystemChrome
      ),
      cardTheme: CardTheme(
        elevation: 0, // Без тени
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Более скругленные углы
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 0.8,
          ), // Тонкая граница
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Отступы карт
        clipBehavior: Clip.antiAlias,
        color: const Color(
          0xFFF0F0F0,
        ), // Явный цвет фона карты (если отличается от surface)
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 0,
        ), // Стандартные отступы ListTile
        dense: false, // Не слишком компактные
      ),
      dividerTheme: DividerThemeData(
        space: 1, // Минимальное пространство у Divider
        thickness: 0.5,
        color: Colors.grey.shade300,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0, // Без тени
        backgroundColor: const Color(0xFFF8F8F8), // Фон панели навигации
        selectedItemColor: const Color(0xFF4A90E2), // Цвет выбранного элемента
        unselectedItemColor: Colors.grey.shade600, // Цвет невыбранного
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true, // Показать текст выбранного
        showUnselectedLabels: false, // Скрыть текст невыбранных
      ),
      // Доп. стили по необходимости (кнопки, поля ввода и т.д.)
    );

    // --- Определяем Темную Тему ---
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Цветовая схема для темной темы
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2), // Тот же seed, но с темной яркостью
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A1A), // Очень темный фон
        surfaceContainerHighest: const Color(
          0xFF2A2A2A,
        ), // Фон "карточек" в темной теме
      ),
      fontFamily: 'Inter',

      // Стили компонентов для темной темы
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            Colors.white, // Цвет иконок и текста на AppBar (для темной темы)
        // Стиль системных оверлеев уже задан глобально через SystemChrome
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade800,
            width: 0.8,
          ), // Граница для темной темы
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF2A2A2A), // Цвет фона карты
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        dense: false,
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Colors.grey.shade800,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF1F1F1F), // Фон панели навигации
        selectedItemColor: const Color(
          0xFF6AAAFF,
        ), // Более светлый синий для акцента в темной теме
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
      // Доп. стили ...
    );

    return MaterialApp(
      title: 'MyStudentApp',
      theme: lightTheme, // Светлая тема
      darkTheme: darkTheme, // Темная тема
      themeMode: themeNotifier.themeMode, // Режим темы из Notifier'а
      // Настройки локализации
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        // Locale('en'),
      ],
      locale: const Locale('ru'),

      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false, // Убираем баннер Debug
    );
  }
}
