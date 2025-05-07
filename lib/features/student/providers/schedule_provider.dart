// lib/features/student/providers/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Наша модель User
import '../../../models/schedule_entry.dart'; // Наша модель ScheduleEntry
import '../../../core/auth_service.dart'; // Для authStateProvider

// Провайдер для стрима расписания текущего пользователя
final scheduleProvider = StreamProvider.autoDispose<List<ScheduleEntry>>((ref) {
  // Следим за состоянием аутентификации
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull; // Получаем текущего пользователя

  // Если пользователя нет или нет ID группы, возвращаем пустой стрим/список
  if (user == null || user.groupId == null || user.groupId!.isEmpty) {
    // Возвращаем стрим с пустым списком
    return Stream.value([]);
  }

  final groupId = user.groupId!;
  final firestore = FirebaseFirestore.instance;

  // Создаем стрим для подколлекции расписания группы
  final snapshots =
      firestore
          .collection('groups')
          .doc(groupId)
          .collection('schedule')
          // Сортируем по дню недели, затем по номеру пары
          .orderBy('dayOfWeek')
          .orderBy('lessonNumber')
          .snapshots();

  // Маппим стрим Firestore Snapshots в стрим List<ScheduleEntry>
  return snapshots.map((snapshot) {
    try {
      // Преобразуем каждый документ в объект ScheduleEntry
      final entries =
          snapshot.docs
              .map((doc) => ScheduleEntry.fromJson(doc.data()))
              .toList();
      return entries;
    } catch (e, stackTrace) {
      // Обрабатываем возможные ошибки парсинга JSON
      print('Error parsing schedule data: $e');
      print(stackTrace);
      // Возвращаем пустой список или можно пробросить ошибку в стрим
      // return Stream.error(e, stackTrace);
      return []; // Пока возвращаем пустой список при ошибке парсинга
    }
  });
});

// Дополнительно: Провайдер для сгруппированного расписания по дням недели
// Ключ - номер дня недели (1-7), значение - список пар на этот день
final groupedScheduleProvider =
    Provider.autoDispose<Map<int, List<ScheduleEntry>>>((ref) {
      // Зависим от основного провайдера расписания
      final asyncSchedule = ref.watch(scheduleProvider);

      // Возвращаем пустую карту, если данных еще нет или ошибка
      return asyncSchedule.maybeWhen(
        data: (scheduleList) {
          final grouped = <int, List<ScheduleEntry>>{};
          for (final entry in scheduleList) {
            // Добавляем запись в список для соответствующего дня недели
            (grouped[entry.dayOfWeek] ??= []).add(entry);
          }
          return grouped;
        },
        orElse: () => {}, // Пустая карта в остальных случаях (loading, error)
      );
    });
