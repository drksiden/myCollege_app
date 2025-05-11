// lib/features/student/providers/grades_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/grade.dart'; // Наша модель Grade
import '../../../core/auth_service.dart'; // Для authStateProvider

// Провайдер для стрима оценок текущего студента
final gradesProvider = StreamProvider.autoDispose<List<Grade>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  // Если пользователя нет, возвращаем пустой стрим
  if (user == null || user.role != 'student') {
    return Stream.value([]);
  }

  final studentId = user.id; // Получаем ID студента
  final firestore = FirebaseFirestore.instance;

  // Запрос к коллекции 'grades'
  final snapshots =
      firestore
          .collection('grades')
          // Фильтруем по ID студента
          .where('studentId', isEqualTo: studentId)
          // Сортируем по дате (сначала новые)
          .orderBy('date', descending: true)
          .snapshots();

  // Маппим в List<Grade>
  return snapshots.map((snapshot) {
    try {
      final grades =
          snapshot.docs.map((doc) => Grade.fromJson(doc.data())).toList();
      return grades;
    } catch (e, stackTrace) {
      print('Error parsing grades data: $e');
      print(stackTrace);
      // Можно пробросить ошибку или вернуть пустой список
      // return Stream.error(e, stackTrace);
      return [];
    }
  });
});

// Провайдер для списка уникальных предметов (для фильтра)
final uniqueSubjectsProvider = Provider.autoDispose<List<String>>((ref) {
  final asyncGrades = ref.watch(gradesProvider);
  return asyncGrades.maybeWhen(
    data: (grades) {
      // Собираем уникальные предметы с помощью Set и сортируем
      final subjects =
          <String>{...grades.map((g) => g.subject)}.toList()..sort();
      // Добавляем опцию "Все" в начало
      return ['Все', ...subjects];
    },
    orElse: () => ['Все'], // По умолчанию только "Все"
  );
});
