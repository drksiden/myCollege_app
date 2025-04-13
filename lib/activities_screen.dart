import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  // Пока что фейковые данные
  final List<Map<String, dynamic>> activities = const [
    {
      'title': 'Олимпиада по математике',
      'description': 'Приглашаем студентов 1-4 курсов принять участие.',
      'date': '2025-04-18',
      'type': 'academic'
    },
    {
      'title': 'Навруз – Весенний праздник',
      'description': 'Будет концерт, угощения и традиционные игры!',
      'date': '2025-03-21',
      'type': 'event'
    },
    {
      'title': 'Ярмарка клубов',
      'description': 'Познакомься с кружками и секциями университета.',
      'date': '2025-04-25',
      'type': 'social'
    },
  ];

  IconData getIcon(String type) {
    switch (type) {
      case 'academic':
        return Icons.school;
      case 'event':
        return Icons.celebration;
      case 'social':
        return Icons.groups;
      default:
        return Icons.info;
    }
  }

  Color getColor(String type) {
    switch (type) {
      case 'academic':
        return Colors.blue;
      case 'event':
        return Colors.orange;
      case 'social':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активности'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final date = DateFormat('d MMMM yyyy', 'ru').format(DateTime.parse(activity['date']));
          final color = getColor(activity['type']);
          final icon = getIcon(activity['type']);

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              title: Text(
                activity['title'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(activity['description']),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
