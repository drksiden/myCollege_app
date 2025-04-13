import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final List<Map<String, dynamic>> allGrades = [
    {'subject': 'Математика', 'score': 90, 'date': '2025-03-01'},
    {'subject': 'Математика', 'score': 85, 'date': '2025-03-15'},
    {'subject': 'Физика', 'score': 70, 'date': '2025-03-10'},
    {'subject': 'Физика', 'score': 75, 'date': '2025-04-01'},
    {'subject': 'Информатика', 'score': 100, 'date': '2025-03-05'},
    {'subject': 'Информатика', 'score': 98, 'date': '2025-04-03'},
  ];

  String selectedSubject = 'Все';

  List<Map<String, dynamic>> getFilteredGrades() {
    if (selectedSubject == 'Все') return allGrades;
    return allGrades.where((g) => g['subject'] == selectedSubject).toList();
  }

  int calculateAverage(List<Map<String, dynamic>> list) {
  if (list.isEmpty) return 0;

  final sum = list.fold(0, (acc, e) => acc + (e['score'] as int));
  return (sum / list.length).round(); // округляем
}

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredGrades();
    final average = calculateAverage(filtered);
    final subjects = ['Все', ...{...allGrades.map((g) => g['subject'])}];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оценки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Фильтр по предметам
            DropdownButton<String>(
  value: selectedSubject,
  items: subjects.map((subject) {
    return DropdownMenuItem<String>(
      value: subject,
      child: Text(subject),
    );
  }).toList(),
  onChanged: (String? value) {
    setState(() {
      selectedSubject = value!;
    });
  },
),

            const SizedBox(height: 16),

            // 📋 Список оценок
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final grade = filtered[index];
                  final formattedDate = DateFormat('d MMM yyyy', 'ru')
                      .format(DateTime.parse(grade['date']));
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.grade),
                      title: Text('${grade['subject']} — ${grade['score']}'),
                      subtitle: Text('Дата: $formattedDate'),
                    ),
                  );
                },
              ),
            ),

            // 📊 Средняя оценка
            Text(
              'Средняя оценка: ${average.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
