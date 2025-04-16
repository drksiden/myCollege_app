// main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Импорт для локализации

Future<void> main() async {
  // 1. Гарантируем инициализацию биндингов Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем локализацию для дат (русский язык)
  await initializeDateFormatting('ru', null);

  // 3. Запускаем приложение
  runApp(const MyStudentApp());
}

class MyStudentApp extends StatelessWidget {
  const MyStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStudentApp',
      theme: ThemeData(
        // Используем цветовую схему на основе основного цвета
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent, // Можете выбрать другой цвет
          // brightness: Brightness.light, // Можно задать светлую/темную тему
        ),
        useMaterial3: true, // Включаем Material 3
        fontFamily: 'Roboto', // Опционально: задать основной шрифт
        // Улучшим вид карточек по умолчанию
        cardTheme: CardTheme(
          elevation: 2, // Небольшая тень
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Скругленные углы
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 8,
          ), // Стандартные отступы
        ),

        // Стиль для AppBar (можно настроить цвет, шрифт и т.д.)
        appBarTheme: const AppBarTheme(
          centerTitle: true, // Центрировать заголовок
          elevation: 1, // Небольшая тень
          // backgroundColor: Colors.blueAccent, // Можно задать цвет
          // foregroundColor: Colors.white, // Цвет текста и иконок
        ),

        // Стиль для BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blueAccent, // Цвет выбранной иконки
          unselectedItemColor: Colors.grey, // Цвет невыбранных иконок
          // backgroundColor: Colors.white, // Цвет фона панели
        ),
      ),
      // Подключаем русскую локализацию для виджетов Flutter (например, DatePicker)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'), // Русский
        // Locale('en'), // Можно добавить английский и другие
      ],
      locale: const Locale('ru'), // Устанавливаем русский как язык по умолчанию

      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
