import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';




Future<void> main() async {
  runApp(const MyStudentApp());
    WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации для русского языка
  await initializeDateFormatting('ru', null);

  runApp(const MyStudentApp());
}

class MyStudentApp extends StatelessWidget {
  const MyStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStudentApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}