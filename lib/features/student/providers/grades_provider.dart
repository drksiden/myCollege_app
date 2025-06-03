// lib/features/student/providers/grades_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/grade.dart';

// Тестовые данные для оценок
final _mockGrades = [
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Программирование',
    grade: '5',
    gradeType: 'Экзамен',
    comment: 'Отличная работа!',
    date: DateTime(2024, 3, 15),
    teacherId: 'teacher_1',
    teacherName: 'Петров П.П.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Программирование',
    grade: '4',
    gradeType: 'Контрольная работа',
    comment: 'Хорошо, но есть ошибки в алгоритме',
    date: DateTime(2024, 3, 1),
    teacherId: 'teacher_1',
    teacherName: 'Петров П.П.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Базы данных',
    grade: '5',
    gradeType: 'Лабораторная работа',
    comment: 'Отличное понимание SQL',
    date: DateTime(2024, 3, 10),
    teacherId: 'teacher_2',
    teacherName: 'Сидорова С.С.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Базы данных',
    grade: '3',
    gradeType: 'Практическая работа',
    comment: 'Нужно повторить нормализацию БД',
    date: DateTime(2024, 2, 28),
    teacherId: 'teacher_2',
    teacherName: 'Сидорова С.С.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Веб-разработка',
    grade: '5',
    gradeType: 'Проект',
    comment: 'Отличный дизайн и функциональность',
    date: DateTime(2024, 3, 5),
    teacherId: 'teacher_3',
    teacherName: 'Козлов К.К.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Веб-разработка',
    grade: '4',
    gradeType: 'Домашнее задание',
    comment: 'Хорошая работа с API',
    date: DateTime(2024, 2, 20),
    teacherId: 'teacher_3',
    teacherName: 'Козлов К.К.',
  ),
  Grade(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Английский язык',
    grade: 'Зачет',
    gradeType: 'Зачет',
    comment: 'Отличное владение техническим английским',
    date: DateTime(2024, 3, 12),
    teacherId: 'teacher_4',
    teacherName: 'Иванова И.И.',
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
