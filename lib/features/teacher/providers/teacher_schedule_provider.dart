// lib/features/teacher/providers/teacher_schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Модели
import '../../../models/schedule_entry.dart';
import '../../../models/user.dart'; // Нужен для teacherId из authStateProvider

// Провайдеры
import '../../../core/auth_service.dart'; // Для получения текущего пользователя (учителя)

// Провайдер для стрима расписания ТЕКУЩЕГО УЧИТЕЛЯ
final teacherScheduleProvider = StreamProvider.autoDispose<
  List<ScheduleEntry>
>((ref) {
  // Следим за состоянием аутентификации, чтобы получить ID учителя
  final authState = ref.watch(authStateProvider);
  final User? teacher = authState.valueOrNull;

  // Если пользователя нет или это не учитель, возвращаем пустой стрим
  if (teacher == null || teacher.role != 'teacher') {
    return Stream.value([]);
  }

  final teacherId = teacher.id; // Получаем ID текущего учителя
  final firestore = FirebaseFirestore.instance;

  // Создаем collectionGroup запрос ко всем подколлекциям с именем 'schedule'
  final snapshots =
      firestore
          .collectionGroup('schedule')
          // Фильтруем записи по ID текущего учителя
          .where('teacherId', isEqualTo: teacherId)
          // Сортируем по дню недели, затем по номеру пары (можно добавить и другие сортировки)
          .orderBy('dayOfWeek')
          .orderBy('lessonNumber')
          .snapshots();

  // Маппим стрим Firestore Snapshots в стрим List<ScheduleEntry>
  return snapshots.map((snapshot) {
    try {
      final entries =
          snapshot.docs
              .map((doc) => ScheduleEntry.fromJson(doc.data()))
              .toList();
      return entries;
    } catch (e, stackTrace) {
      print('Error parsing teacher schedule data: $e');
      print(stackTrace);
      // Можно пробросить ошибку или вернуть пустой список
      // return Stream.error(e, stackTrace);
      return [];
    }
  });
});

// Провайдер для сгруппированного расписания учителя по дням недели
final groupedTeacherScheduleProvider = Provider.autoDispose<
  Map<int, List<ScheduleEntry>>
>((ref) {
  // Зависим от основного провайдера расписания учителя
  final asyncSchedule = ref.watch(teacherScheduleProvider);

  return asyncSchedule.maybeWhen(
    data: (scheduleList) {
      final grouped = <int, List<ScheduleEntry>>{};
      for (final entry in scheduleList) {
        (grouped[entry.dayOfWeek] ??= []).add(entry);
      }
      // Сортируем пары внутри каждого дня по времени начала (на всякий случай)
      grouped.forEach((day, lessons) {
        lessons.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
      return grouped;
    },
    orElse: () => {}, // Пустая карта в остальных случаях
  );
});
