// Пример заглушки для SchedulePage (создай schedule_page.dart)
import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: const Center(child: Text('Страница Расписания')),
    );
  }
}
