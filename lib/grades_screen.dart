import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../mock_data.dart'; // Импортируем mock данные

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  // Используем данные из mock_data.dart
  final List<Map<String, dynamic>> allGrades = mockGrades;

  // Состояние для выбранного предмета в фильтре
  String selectedSubject = 'Все';

  // Функция для получения отфильтрованного списка оценок
  List<Map<String, dynamic>> getFilteredGrades() {
    if (selectedSubject == 'Все') {
      // Сортируем все оценки по дате (от новых к старым) для наглядности
      final sortedList = List<Map<String, dynamic>>.from(allGrades);
      sortedList.sort(
        (a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
      );
      return sortedList;
    }
    // Фильтруем по предмету и сортируем по дате
    final filteredList =
        allGrades.where((g) => g['subject'] == selectedSubject).toList();
    filteredList.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );
    return filteredList;
  }

  // Функция для расчета среднего балла (возвращает double)
  double calculateAverage(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return 0.0; // Возвращаем double 0.0

    // Считаем сумму как double для точности
    final sum = list.fold(0.0, (acc, e) => acc + (e['score'] as int));
    return sum / list.length; // Просто делим, без округления здесь
  }

  @override
  Widget build(BuildContext context) {
    // Получаем отфильтрованные данные и средний балл
    final filtered = getFilteredGrades();
    final average = calculateAverage(filtered);
    // Формируем список уникальных предметов для Dropdown, добавляя 'Все'
    final subjects = [
      'Все',
      ...{
        ...allGrades.map((g) => g['subject']),
      }, // Используем Set {...} для уникальности
    ];
    // Флаг, есть ли оценки для отображения в текущем фильтре
    final bool hasGrades = filtered.isNotEmpty;

    return Scaffold(
      // AppBar остается стандартным
      appBar: AppBar(
        title: const Text('Оценки'),
        // Можно добавить действия, например, кнопку обновления (пока без логики)
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: () {
        //       // TODO: Логика обновления данных (когда будет Firebase)
        //     },
        //   ),
        // ],
      ),
      // Основное тело экрана с отступами
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Растягиваем дочерние по ширине
          children: [
            const SizedBox(height: 16), // Вертикальный отступ
            // 🔍 Виджет фильтра по предметам
            DropdownButtonFormField<String>(
              value: selectedSubject, // Текущее выбранное значение
              // Стилизация из InputDecorator для соответствия теме
              decoration: InputDecoration(
                labelText: 'Предмет', // Метка над полем
                border: OutlineInputBorder(
                  // Рамка вокруг поля
                  borderRadius: BorderRadius.circular(12),
                ),
                // Внутренние отступы в поле
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              // Формируем элементы списка Dropdown
              items:
                  subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
              // Обработчик смены значения в Dropdown
              onChanged: (String? value) {
                if (value != null) {
                  // Обновляем состояние при выборе нового предмета
                  setState(() {
                    selectedSubject = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16), // Вертикальный отступ
            // 📋 Список оценок ИЛИ сообщение об их отсутствии
            Expanded(
              // Используем AnimatedSwitcher для плавной смены контента
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                // Анимация появления/исчезновения
                transitionBuilder:
                    (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                // Контент зависит от наличия отфильтрованных оценок
                child:
                    hasGrades
                        ? ListView.builder(
                          // Уникальный ключ для состояния со списком
                          key: const ValueKey('grades_list'),
                          itemCount:
                              filtered.length, // Количество элементов в списке
                          itemBuilder: (context, index) {
                            final grade =
                                filtered[index]; // Данные текущей оценки
                            // Форматируем дату с годом
                            final formattedDate = DateFormat(
                              'd MMM yy',
                              'ru',
                            ).format(DateTime.parse(grade['date']));

                            // Карточка для отображения оценки
                            return Card(
                                  // Использует cardTheme из MaterialApp
                                  child: ListTile(
                                    // Иконка слева в кружке
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                      child: const Icon(Icons.grade_outlined),
                                    ),
                                    // Название предмета
                                    title: Text(grade['subject']),
                                    // Подзаголовок с оценкой и датой
                                    subtitle: Text(
                                      'Оценка: ${grade['score']} / Дата: $formattedDate',
                                    ),
                                    // Оценка справа, цвет зависит от значения
                                    trailing: Text(
                                      '${grade['score']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        // Цвет в зависимости от балла
                                        color:
                                            grade['score'] >= 85
                                                ? Colors.green.shade600
                                                : (grade['score'] >= 70
                                                    ? Colors.orange.shade700
                                                    : Colors.red.shade600),
                                      ),
                                    ),
                                  ),
                                )
                                // Анимация появления карточки
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideY(begin: 0.2, end: 0.0, duration: 300.ms);
                          },
                        )
                        : Center(
                          // Отображается, если список пуст
                          // Уникальный ключ для состояния без оценок
                          key: const ValueKey('no_grades'),
                          child:
                              Padding(
                                // Добавим отступы для текста
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  // Сообщение зависит от фильтра
                                  selectedSubject == 'Все'
                                      ? 'Нет оценок для отображения'
                                      : 'Нет оценок по предмету "$selectedSubject"',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ).animate().fadeIn(), // Анимация появления текста
                        ),
              ),
            ),
            const SizedBox(height: 16), // Вертикальный отступ
            // 📊 Средняя оценка (показываем только если есть оценки)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // Анимация появления/исчезновения и масштабирования
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              // Контент зависит от наличия оценок и выбранного предмета (через Key)
              child:
                  hasGrades
                      ? Text(
                        'Средняя оценка: ${average.toStringAsFixed(1)}',
                        // Ключ зависит от выбранного предмета, чтобы AnimatedSwitcher
                        // корректно срабатывал при смене фильтра
                        key: ValueKey<String>('avg_$selectedSubject'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // Используем основной цвет темы
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      )
                      // Если оценок нет, показываем пустой SizedBox
                      : SizedBox(key: const ValueKey('no_avg')),
            ),
            const SizedBox(height: 16), // Нижний отступ
          ],
        ),
      ),
    );
  }
}
