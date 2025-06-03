// lib/features/student/providers/grades_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/grade.dart';

// Тестовые данные для оценок
final _mockGrades = [
  // Программирование
  Grade(
    id: '1',
    subject: 'Программирование',
    teacher: 'Петров П.П.',
    date: DateTime(2024, 1, 15),
    value: 4.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Хорошее понимание базовых концепций',
  ),
  Grade(
    id: '2',
    subject: 'Программирование',
    teacher: 'Петров П.П.',
    date: DateTime(2024, 1, 20),
    value: 5.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Отличная работа над проектом',
  ),
  Grade(
    id: '3',
    subject: 'Программирование',
    teacher: 'Петров П.П.',
    date: DateTime(2024, 2, 12),
    value: 1.0,
    semester: 1,
    isNumeric: false,
    isPassFail: true,
    comment: 'Зачет по практической работе',
  ),

  // Базы данных
  Grade(
    id: '4',
    subject: 'Базы данных',
    teacher: 'Сидорова С.С.',
    date: DateTime(2024, 1, 18),
    value: 3.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Требуется улучшение в SQL-запросах',
  ),
  Grade(
    id: '5',
    subject: 'Базы данных',
    teacher: 'Сидорова С.С.',
    date: DateTime(2024, 2, 1),
    value: 4.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Улучшение результатов в последней контрольной',
  ),
  Grade(
    id: '6',
    subject: 'Базы данных',
    teacher: 'Сидорова С.С.',
    date: DateTime(2024, 2, 15),
    value: 0.0,
    semester: 1,
    isNumeric: false,
    isPassFail: true,
    comment: 'Не сдал финальный проект',
  ),

  // Веб-разработка
  Grade(
    id: '7',
    subject: 'Веб-разработка',
    teacher: 'Козлов К.К.',
    date: DateTime(2024, 1, 22),
    value: 5.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Отличная реализация проекта',
  ),
  Grade(
    id: '8',
    subject: 'Веб-разработка',
    teacher: 'Козлов К.К.',
    date: DateTime(2024, 2, 5),
    value: 4.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Хорошая работа над адаптивным дизайном',
  ),

  // Английский язык
  Grade(
    id: '9',
    subject: 'Английский язык',
    teacher: 'Иванова И.И.',
    date: DateTime(2024, 1, 25),
    value: 3.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Требуется улучшение грамматики',
  ),
  Grade(
    id: '10',
    subject: 'Английский язык',
    teacher: 'Иванова И.И.',
    date: DateTime(2024, 2, 8),
    value: 4.0,
    semester: 1,
    isNumeric: true,
    isPassFail: false,
    comment: 'Улучшение разговорных навыков',
  ),
];

// Провайдер для получения всех оценок
final gradesProvider = FutureProvider<List<Grade>>((ref) async {
  // В реальном приложении здесь будет запрос к Firestore
  // Сейчас возвращаем тестовые данные
  await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
  return _mockGrades;
});

// Провайдер для получения уникальных предметов
final uniqueSubjectsProvider = Provider<List<String>>((ref) {
  final grades = ref.watch(gradesProvider).value ?? [];
  final subjects = grades.map((g) => g.subject).toSet().toList();
  subjects.sort(); // Сортируем по алфавиту
  return ['Все', ...subjects]; // Добавляем опцию "Все" в начало списка
});
