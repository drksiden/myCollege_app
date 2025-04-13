import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  final List<Map<String, dynamic>> schedule = const [
    {
      'day': 'Понедельник',
      'lessons': [
        {'subject': 'Математика', 'teacher': 'А. Тлеуов', 'time': '08:00 - 09:30'},
        {'subject': 'Физика', 'teacher': 'С. Нурпеисов', 'time': '09:40 - 11:10'},
      ]
    },
    {
      'day': 'Вторник',
      'lessons': [
        {'subject': 'Информатика', 'teacher': 'М. Кабылова', 'time': '08:00 - 09:30'},
        {'subject': 'Английский язык', 'teacher': 'Ж. Тойганбаева', 'time': '09:40 - 11:10'},
      ]
    },
    {
      'day': 'Среда',
      'lessons': [
        {'subject': 'История', 'teacher': 'Б. Жумагалиева', 'time': '08:00 - 09:30'},
      ]
    },
    {
      'day': 'Четверг',
      'lessons': [
        {'subject': 'Математика', 'teacher': 'А. Тлеуов', 'time': '08:00 - 09:30'},
      ]
    },
    {
      'day': 'Пятница',
      'lessons': [
        {'subject': 'Физкультура', 'teacher': 'А. Айтмуратов', 'time': '10:00 - 11:30'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание на неделю'),
      ),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final daySchedule = schedule[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: ExpansionTile(
                title: Text(
                  daySchedule['day'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: (daySchedule['lessons'] as List)
                    .map((lesson) => ListTile(
                          title: Text(lesson['subject']),
                          subtitle: Text('Преподаватель: ${lesson['teacher']}'),
                          trailing: Text(lesson['time']),
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
