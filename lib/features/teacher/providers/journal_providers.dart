// lib/features/teacher/providers/journal_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart'; // Для firstWhereOrNull

// Модели
import '../../../models/user.dart';
import '../../../models/group.dart'; // <-- ИСПОЛЬЗУЕМ МОДЕЛЬ GROUP
import '../../../models/grade.dart';
import '../../../models/attendance_record.dart';
import '../../../models/schedule_entry.dart';

// Провайдеры
import '../../../core/auth_service.dart';
import 'teacher_schedule_provider.dart';

final _firestore = FirebaseFirestore.instance;

// --- Класс для хранения информации о группе и предметах учителя ---
class GroupInfo {
  final String id;
  final String name;
  final List<String> subjects; // Предметы, которые учитель ведет в этой группе

  GroupInfo({required this.id, required this.name, required this.subjects});
}
// --------------------------------------------------------------

// --- Провайдер для получения групп и предметов, которые ведет учитель ---
// Возвращает List<GroupInfo>
final teacherSubjectsAndGroupsProvider =
    FutureProvider.autoDispose<List<GroupInfo>>((ref) async {
      final teacherScheduleAsync = ref.watch(teacherScheduleProvider.future);
      final List<ScheduleEntry> schedule = await teacherScheduleAsync;

      if (schedule.isEmpty) {
        return [];
      }

      // Группируем предметы по groupId
      final Map<String, Set<String>> subjectsByGroupId = {};
      for (final entry in schedule) {
        if (entry.groupId != null && entry.groupId!.isNotEmpty) {
          subjectsByGroupId.putIfAbsent(entry.groupId!, () => <String>{});
          subjectsByGroupId[entry.groupId!]!.add(entry.subject);
        }
      }

      final groupIds = subjectsByGroupId.keys.toList();
      if (groupIds.isEmpty) return [];

      final List<GroupInfo> result = [];

      try {
        // Запрашиваем документы групп по найденным ID
        // Разбиваем на чанки по 10 ID для whereIn запроса Firestore
        final groupChunks = groupIds.slices(10); // Используем пакет collection
        List<Group> groups = [];

        for (final chunk in groupChunks) {
          if (chunk.isEmpty) continue;
          final groupSnapshots =
              await _firestore
                  .collection('groups')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();
          groups.addAll(
            groupSnapshots.docs.map((doc) {
              final groupData = Group.fromJson(doc.data()); // Парсим данные
              return groupData.copyWith(id: doc.id); // Добавляем ID документа
            }),
          );
        }

        // Создаем GroupInfo для каждой найденной группы
        for (final group in groups) {
          final groupId = group.id;
          if (groupId != null && subjectsByGroupId.containsKey(groupId)) {
            result.add(
              GroupInfo(
                id: groupId, // Используем ID из объекта Group
                name: group.name,
                subjects: subjectsByGroupId[groupId]!.toList()..sort(),
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        debugPrint("Error fetching groups for teacher: $e\n$stackTrace");
        // Можно вернуть заглушку или пробросить ошибку
        return []; // Возвращаем пустой список при ошибке
      }

      // Сортируем результат по имени группы
      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    });

// --- Провайдер для получения студентов выбранной группы ---
// Используем .family для передачи groupId
final groupStudentsProvider = StreamProvider.autoDispose
    .family<List<User>, String>((ref, groupId) {
      if (groupId.isEmpty) {
        return Stream.value([]);
      }
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('groupId', isEqualTo: groupId)
          .orderBy('lastName') // Сортируем по фамилии
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => User.fromJson(doc.data()..['id'] = doc.id))
                    .toList(),
          );
      // Добавляем 'id' вручную, если fromJson его ожидает
    });

// --- Провайдер для получения оценок по группе и предмету ---
final groupSubjectGradesProvider = StreamProvider.autoDispose
    .family<List<Grade>, ({String groupId, String subject})>((ref, params) {
      if (params.groupId.isEmpty || params.subject.isEmpty) {
        return Stream.value([]);
      }
      return _firestore
          .collection('grades')
          .where('groupId', isEqualTo: params.groupId)
          .where('subject', isEqualTo: params.subject)
          .orderBy('date', descending: true) // Сначала новые оценки
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Grade.fromJson(doc.data())).toList(),
          );
    });

// --- Провайдер для получения посещаемости по группе, дате и номеру урока ---
// (Может потребоваться доработка в зависимости от того, как будет выбираться урок)
final attendanceProvider = StreamProvider.autoDispose.family<
  List<AttendanceRecord>,
  ({String groupId, DateTime date, int lessonNumber})
>((ref, params) {
  if (params.groupId.isEmpty || params.lessonNumber <= 0) {
    return Stream.value([]);
  }
  // Firestore Timestamp для начала и конца выбранного дня
  final startOfDay = Timestamp.fromDate(
    DateTime(params.date.year, params.date.month, params.date.day),
  );
  final endOfDay = Timestamp.fromDate(
    DateTime(params.date.year, params.date.month, params.date.day, 23, 59, 59),
  );

  return _firestore
      .collection('attendance')
      .where('groupId', isEqualTo: params.groupId)
      .where('lessonNumber', isEqualTo: params.lessonNumber)
      // Фильтруем по Timestamp дня
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .where('date', isLessThanOrEqualTo: endOfDay)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => AttendanceRecord.fromJson(doc.data()))
                .toList(),
      );
});

// === Функции для изменения данных (CRUD) ===
// Их лучше реализовать как методы сервиса (FirestoreService) или прямо здесь,
// но вызывать их нужно будет через ref.read(provider).addGrade(...) и т.п.

final journalServiceProvider = Provider((ref) => JournalService(ref));

class JournalService {
  final Ref _ref;
  JournalService(this._ref);

  // --- Оценки ---
  Future<void> addOrUpdateGrade(Grade grade) async {
    final teacher = _ref.read(authStateProvider).valueOrNull;
    if (teacher == null) throw Exception("Учитель не авторизован");

    // Подготавливаем данные для записи
    final gradeData =
        grade
            .copyWith(teacherId: teacher.id, teacherName: teacher.shortName)
            .toJson();

    // Ищем существующую оценку с такими же параметрами
    final query = _firestore
        .collection('grades')
        .where('studentId', isEqualTo: grade.studentId)
        .where('subject', isEqualTo: grade.subject)
        .where('gradeType', isEqualTo: grade.gradeType)
        .where('date', isEqualTo: Timestamp.fromDate(grade.date))
        .limit(1);

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      // Если нашли существующую оценку - обновляем её
      final docId = snapshot.docs.first.id;
      await _firestore.collection('grades').doc(docId).update(gradeData);
    } else {
      // Если не нашли - создаем новую запись
      await _firestore.collection('grades').add(gradeData);
    }

    // Инвалидируем кэш провайдера оценок
    _ref.invalidate(
      groupSubjectGradesProvider((
        groupId: grade.groupId ?? '',
        subject: grade.subject,
      )),
    );
  }

  Future<void> deleteGrade(String gradeId) async {
    // Получаем данные оценки перед удалением для инвалидации кэша
    final gradeDoc = await _firestore.collection('grades').doc(gradeId).get();
    if (!gradeDoc.exists) return;

    final grade = Grade.fromJson(gradeDoc.data()!);
    await _firestore.collection('grades').doc(gradeId).delete();

    // Инвалидируем кэш провайдера оценок
    if (grade.groupId != null) {
      _ref.invalidate(
        groupSubjectGradesProvider((
          groupId: grade.groupId!,
          subject: grade.subject,
        )),
      );
    }
  }

  // --- Посещаемость ---
  Future<void> addOrUpdateAttendanceRecord(AttendanceRecord record) async {
    final teacher = _ref.read(authStateProvider).valueOrNull;
    if (teacher == null) throw Exception("Учитель не авторизован");

    // Ищем существующую запись для этого студента, на эту дату и пару
    final startOfDay = Timestamp.fromDate(
      DateTime(record.date.year, record.date.month, record.date.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
        23,
        59,
        59,
      ),
    );

    final query = _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: record.studentId)
        .where('groupId', isEqualTo: record.groupId)
        .where('lessonNumber', isEqualTo: record.lessonNumber)
        .where(
          'subject',
          isEqualTo: record.subject,
        ) // Добавим предмет для точности
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .limit(1);

    final snapshot = await query.get();
    final updatedRecordData =
        record
            .copyWith(
              recordedByTeacherId: teacher.id,
              timestamp: DateTime.now(), // Обновляем время записи
            )
            .toJson();

    if (snapshot.docs.isNotEmpty) {
      // Запись существует - обновляем
      final docId = snapshot.docs.first.id;
      await _firestore
          .collection('attendance')
          .doc(docId)
          .update(updatedRecordData);
    } else {
      // Записи нет - создаем новую
      await _firestore.collection('attendance').add(updatedRecordData);
    }

    // Инвалидируем кэш провайдера посещаемости
    _ref.invalidate(
      attendanceProvider((
        groupId: record.groupId,
        date: record.date,
        lessonNumber: record.lessonNumber,
      )),
    );
  }

  // Удаление записи о посещаемости (может и не нужно?)
  // Future<void> deleteAttendanceRecord(...) async { ... }
}

final teacherLessonsForDayProvider = FutureProvider.autoDispose.family<
  List<ScheduleEntry>,
  ({String groupId, String subject, DateTime date})
>((ref, params) async {
  if (params.groupId.isEmpty || params.subject.isEmpty) {
    return [];
  }
  final teacher = ref.watch(authStateProvider).valueOrNull;
  if (teacher == null) return [];

  // Рассчитываем день недели (1 = Пн, ..., 7 = Вс)
  final dayOfWeek = params.date.weekday;

  // Получаем общее расписание учителя (из кэша или загружаем)
  // Используем teacherScheduleProvider, чтобы не делать лишний запрос к Firestore,
  // а только отфильтровать уже загруженные данные.
  final allTeacherSchedule = await ref.watch(teacherScheduleProvider.future);

  // Фильтруем расписание по нужным параметрам
  final lessons =
      allTeacherSchedule
          .where(
            (entry) =>
                entry.groupId == params.groupId &&
                entry.subject == params.subject &&
                entry.dayOfWeek == dayOfWeek,
          )
          .toList();

  // Сортируем по номеру урока
  lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));

  return lessons;
});
