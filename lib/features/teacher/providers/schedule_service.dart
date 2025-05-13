import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../../../core/auth_service.dart';

final _firestore = FirebaseFirestore.instance;

final scheduleServiceProvider = Provider((ref) => ScheduleService(ref));

class ScheduleService {
  final Ref _ref;
  ScheduleService(this._ref);

  /// Сохраняет или обновляет запись расписания
  Future<void> saveScheduleEntry(
    ScheduleEntry entry, {
    bool isUpdate = false,
  }) async {
    final teacher = _ref.read(authStateProvider).valueOrNull;
    if (teacher == null) throw Exception("Учитель не авторизован");

    // Подготавливаем данные для записи
    final entryData = entry.toJson();

    try {
      if (isUpdate && entry.id != null) {
        // Обновляем существующую запись
        await _firestore.collection('schedule').doc(entry.id).update(entryData);
      } else {
        // Создаем новую запись
        await _firestore.collection('schedule').add(entryData);
      }
    } catch (e) {
      throw Exception("Ошибка при сохранении расписания: $e");
    }
  }

  /// Удаляет запись расписания
  Future<void> deleteScheduleEntry(String entryId) async {
    try {
      await _firestore.collection('schedule').doc(entryId).delete();
    } catch (e) {
      throw Exception("Ошибка при удалении записи расписания: $e");
    }
  }

  /// Проверяет наличие конфликтов в расписании
  Future<bool> hasScheduleConflict(ScheduleEntry entry) async {
    try {
      // Проверяем конфликты по группе
      final groupConflicts =
          await _firestore
              .collection('schedule')
              .where('groupId', isEqualTo: entry.groupId)
              .where('dayOfWeek', isEqualTo: entry.dayOfWeek)
              .where('lessonNumber', isEqualTo: entry.lessonNumber)
              .get();

      // Если это обновление, исключаем текущую запись из проверки
      if (entry.id != null) {
        return groupConflicts.docs.any((doc) => doc.id != entry.id);
      }

      return groupConflicts.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Ошибка при проверке конфликтов расписания: $e");
    }
  }

  /// Обновляет порядок урока в расписании
  Future<void> updateLessonOrder(
    String entryId,
    String groupId,
    int newOrder,
  ) async {
    if (groupId.isEmpty || entryId.isEmpty) {
      throw Exception(
        'GroupID и EntryID не могут быть пустыми для обновления порядка.',
      );
    }
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('schedule')
        .doc(entryId)
        .update({'lessonNumber': newOrder});
  }
}
