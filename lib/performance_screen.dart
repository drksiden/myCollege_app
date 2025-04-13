import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attendance_repository.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final List<String> months = List.generate(12, (i) => DateFormat.MMMM('ru').format(DateTime(2025, i + 1)));
  String selectedMonth = DateFormat.MMMM('ru').format(DateTime.now());

  Map<String, List<Map<String, dynamic>>> monthlyAttendance = {};

  // Праздники (можно дополнить)
  final List<DateTime> holidays = [
    DateTime(2025, 1, 1), // Новый год
    DateTime(2025, 3, 8), // 8 марта
    DateTime(2025, 5, 9), // День Победы
  ];

  @override
  void initState() {
    super.initState();
    _generateAttendance();
    monthlyAttendance = AttendanceRepository().monthlyAttendance;

  }

  void _generateAttendance() {
    for (int i = 1; i <= 12; i++) {
      final firstDay = DateTime(2025, i, 1);
      final daysInMonth = DateUtils.getDaysInMonth(2025, i);
      List<Map<String, dynamic>> days = [];

      for (int d = 1; d <= daysInMonth; d++) {
        DateTime date = DateTime(2025, i, d);

        // Проверка на выходной
        bool isWeekend = date.weekday == 6 || date.weekday == 7;
        bool isHoliday = holidays.any((h) => h.year == date.year && h.month == date.month && h.day == date.day);

        // Пропускаем выходные и праздники
        if (isWeekend || isHoliday) {
          days.add({'date': date, 'status': null});
        } else {
          // Случайная успеваемость
          bool attended = date.day % (i + 2) != 0;
          days.add({'date': date, 'status': attended ? '✓' : 'X'});
        }
      }

      monthlyAttendance[DateFormat.MMMM('ru').format(firstDay)] = days;
    }
  }

  double calculateAverage(String month) {
    final data = monthlyAttendance[month]!;
    final activeDays = data.where((e) => e['status'] != null);
    if (activeDays.isEmpty) return 0;
    final attendedDays = activeDays.where((e) => e['status'] == '✓').length;
    return (attendedDays / activeDays.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final currentData = monthlyAttendance[selectedMonth]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Успеваемость')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Средняя успеваемость: ${calculateAverage(selectedMonth).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Выбор месяца
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedMonth,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                }
              },
              items: months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(month, style: const TextStyle(fontSize: 20)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Сетка дней
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: currentData.length,
              itemBuilder: (context, index) {
                final item = currentData[index];
                final date = item['date'] as DateTime;
                final status = item['status'];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('d').format(date)),
                        const SizedBox(height: 4),
                        if (status != null)
                          CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                status == '✓' ? Colors.green : Colors.red,
                            child: Text(
                              status,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          )
                        else
                          const Text(
                            '—',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
