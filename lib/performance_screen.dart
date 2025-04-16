// performance_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // Импорт календаря
import 'package:percent_indicator/percent_indicator.dart'; // Импорт индикатора
import 'package:flutter_animate/flutter_animate.dart'; // Для анимации индикатора

// Переносим генерацию данных и праздники из State для чистоты
// (В будущем это будет получаться извне)
final List<DateTime> _holidays = [
  DateTime(2025, 1, 1),
  DateTime(2025, 3, 8),
  DateTime(2025, 3, 21), // Добавим Навруз
  DateTime(2025, 3, 22), DateTime(2025, 3, 23), DateTime(2025, 5, 1),
  DateTime(2025, 5, 7), DateTime(2025, 5, 9), // ... другие праздники
];

Map<String, List<Map<String, dynamic>>> _generateAttendance() {
  Map<String, List<Map<String, dynamic>>> monthlyAttendance = {};
  // Важно: для TableCalendar лучше хранить данные привязанные к DateTime, а не к строке месяца
  // Мы сгенерируем данные сразу для всего года для простоты примера
  Map<DateTime, String?> dailyStatus = {}; // DateTime -> '✓' или 'X'

  final now = DateTime.now(); // Используем текущий год или целевой
  final year = 2025; // Используем 2025 как в примере

  for (int month = 1; month <= 12; month++) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(year, month, day);
      DateTime dateOnly = DateTime(
        date.year,
        date.month,
        date.day,
      ); // Убираем время

      bool isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      bool isHoliday = _holidays.any(
        (h) => isSameDay(h, date),
      ); // Функция isSameDay из table_calendar

      if (!isWeekend && !isHoliday) {
        // "Случайная" посещаемость (как в вашем примере)
        bool attended = date.day % (month + 2) != 0;
        dailyStatus[dateOnly] = attended ? '✓' : 'X';
      } else {
        dailyStatus[dateOnly] = null; // Не учебный день
      }
    }
  }
  // Сохраняем данные (если нужно будет по месяцам) - сейчас не используется
  // for (var entry in dailyStatus.entries) {
  //    final monthStr = DateFormat.MMMM('ru').format(entry.key);
  //    if (monthlyAttendance[monthStr] == null) monthlyAttendance[monthStr] = [];
  //    monthlyAttendance[monthStr]!.add({'date': entry.key, 'status': entry.value});
  // }
  // Вернем данные в формате, удобном для TableCalendar
  return {
    'all':
        dailyStatus.entries
            .map((e) => {'date': e.key, 'status': e.value})
            .toList(),
  };
}

// Данные теперь генерируются один раз
final Map<DateTime, String?> _attendanceData = Map.fromEntries(
  _generateAttendance()['all']!.map(
    (e) => MapEntry(e['date'] as DateTime, e['status'] as String?),
  ),
);

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  // Состояние календаря
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(
    2025,
    DateTime.now().month,
    DateTime.now().day,
  ); // Фокус на текущем месяце 2025
  DateTime? _selectedDay;

  // Функция для получения событий (статусов) для дня
  List<Widget> _getEventsForDay(DateTime day) {
    final status = _attendanceData[DateTime(day.year, day.month, day.day)];
    if (status != null) {
      return [
        Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: status == '✓' ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color:
                  status == '✓' ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ),
      ];
    }
    return [];
  }

  double calculateAverageForMonth(DateTime month) {
    final monthData = _attendanceData.entries.where((e) {
      final date = e.key;
      return date.year == month.year &&
          date.month == month.month &&
          e.value != null; // Учебные дни месяца
    });

    if (monthData.isEmpty) return 0.0;

    final attendedDays = monthData.where((e) => e.value == '✓').length;
    return (attendedDays / monthData.length) * 100;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Выбираем сегодняшний день при запуске
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthAverage = calculateAverageForMonth(_focusedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Посещаемость')),
      body: Column(
        children: [
          // Индикатор среднего процента
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 10.0,
                  percent:
                      currentMonthAverage / 100.0, // Значение от 0.0 до 1.0
                  center: Text(
                    "${currentMonthAverage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Посещаемость за ${DateFormat.MMMM('ru').format(_focusedDay)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blueAccent,
                  backgroundColor: Colors.grey.shade300,
                )
                .animate() // Анимируем появление индикатора
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms),
          ),

          // Календарь
          TableCalendar(
            locale: 'ru_RU', // Устанавливаем локаль для календаря
            firstDay: DateTime(2025, 1, 1), // Начальная дата
            lastDay: DateTime(2025, 12, 31), // Конечная дата
            focusedDay: _focusedDay, // Текущий видимый месяц
            calendarFormat: _calendarFormat,
            selectedDayPredicate:
                (day) =>
                    isSameDay(_selectedDay, day), // Выделение выбранного дня
            eventLoader: _getEventsForDay, // Загрузка маркеров статуса
            holidayPredicate: (day) {
              // Выделение праздников
              return _holidays.any((holiday) => isSameDay(holiday, day));
            },

            // Стиль календаря
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withAlpha(
                  128,
                ), // Выделение сегодняшнего дня
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blueAccent, // Выделение выбранного дня
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                // Общий стиль для маркеров (не используется т.к. _getEventsForDay возвращает Widget)
                // color: Colors.red,
                // shape: BoxShape.rectangle,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.red[600],
              ), // Стиль выходных
              holidayDecoration: BoxDecoration(
                // Стиль праздников
                border: Border.all(color: Colors.orangeAccent, width: 1.4),
                shape: BoxShape.circle,
              ),
              holidayTextStyle: const TextStyle(color: Colors.orangeAccent),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Скрыть кнопку смены формата (неделя/месяц)
              titleCentered: true, // Центрировать заголовок месяца
            ),

            onDaySelected: (selectedDay, focusedDay) {
              // Обновляем состояние при выборе дня
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay =
                      focusedDay; // Фокусируемся на выбранном дне/месяце
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Обновляем фокус при смене месяца
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          // Можно добавить расширенную информацию о выбранном дне, если нужно
          // if (_selectedDay != null)
          //   Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text('Выбран день: ${DateFormat.yMd('ru').format(_selectedDay!)} Статус: ${_attendanceData[_selectedDay!] ?? 'Нет данных'}'),
          //   )
        ],
      ),
    );
  }
}
