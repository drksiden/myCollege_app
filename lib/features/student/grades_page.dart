// Пример заглушки для GradesPage (создай grades_page.dart)
import 'package:flutter/material.dart';

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оценки')),
      body: const Center(child: Text('Страница Оценок')),
    );
  }
}
