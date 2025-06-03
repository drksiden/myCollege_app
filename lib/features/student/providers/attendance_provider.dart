import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/attendance.dart';

// Тестовые данные для посещаемости
final _mockAttendance = [
  // Программирование
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Программирование',
    date: DateTime(2024, 3, 15),
    status: AttendanceStatus.present,
    teacherId: 'teacher_1',
    teacherName: 'Петров П.П.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Программирование',
    date: DateTime(2024, 3, 14),
    status: AttendanceStatus.late,
    comment: 'Опоздал на 10 минут',
    teacherId: 'teacher_1',
    teacherName: 'Петров П.П.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Программирование',
    date: DateTime(2024, 3, 13),
    status: AttendanceStatus.absent,
    comment: 'Не предупредил об отсутствии',
    teacherId: 'teacher_1',
    teacherName: 'Петров П.П.',
  ),

  // Базы данных
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Базы данных',
    date: DateTime(2024, 3, 15),
    status: AttendanceStatus.present,
    teacherId: 'teacher_2',
    teacherName: 'Сидорова С.С.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Базы данных',
    date: DateTime(2024, 3, 14),
    status: AttendanceStatus.excused,
    comment: 'Справка от врача',
    teacherId: 'teacher_2',
    teacherName: 'Сидорова С.С.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Базы данных',
    date: DateTime(2024, 3, 13),
    status: AttendanceStatus.present,
    teacherId: 'teacher_2',
    teacherName: 'Сидорова С.С.',
  ),

  // Веб-разработка
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Веб-разработка',
    date: DateTime(2024, 3, 15),
    status: AttendanceStatus.present,
    teacherId: 'teacher_3',
    teacherName: 'Козлов К.К.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Веб-разработка',
    date: DateTime(2024, 3, 14),
    status: AttendanceStatus.present,
    teacherId: 'teacher_3',
    teacherName: 'Козлов К.К.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Веб-разработка',
    date: DateTime(2024, 3, 13),
    status: AttendanceStatus.late,
    comment: 'Опоздал на 5 минут',
    teacherId: 'teacher_3',
    teacherName: 'Козлов К.К.',
  ),

  // Английский язык
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Английский язык',
    date: DateTime(2024, 3, 15),
    status: AttendanceStatus.present,
    teacherId: 'teacher_4',
    teacherName: 'Иванова И.И.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Английский язык',
    date: DateTime(2024, 3, 14),
    status: AttendanceStatus.absent,
    comment: 'Не предупредил об отсутствии',
    teacherId: 'teacher_4',
    teacherName: 'Иванова И.И.',
  ),
  Attendance(
    studentId: 'test_student_1',
    studentName: 'Иванов Иван',
    groupId: 'П2Г',
    subject: 'Английский язык',
    date: DateTime(2024, 3, 13),
    status: AttendanceStatus.present,
    teacherId: 'teacher_4',
    teacherName: 'Иванова И.И.',
  ),
];

// Провайдер для получения всех записей посещаемости
final attendanceProvider = FutureProvider<List<Attendance>>((ref) async {
  // В реальном приложении здесь будет запрос к Firestore
  // Сейчас возвращаем тестовые данные
  await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
  return _mockAttendance;
});

// Провайдер для получения уникальных предметов
final uniqueSubjectsProvider = Provider<List<String>>((ref) {
  final attendance = ref.watch(attendanceProvider).value ?? [];
  final subjects = attendance.map((a) => a.subject).toSet().toList();
  subjects.sort(); // Сортируем по алфавиту
  return ['Все', ...subjects]; // Добавляем опцию "Все" в начало списка
});

// Провайдер для получения статистики посещаемости
final attendanceStatsProvider =
    Provider<Map<String, Map<AttendanceStatus, int>>>((ref) {
      final attendance = ref.watch(attendanceProvider).value ?? [];
      final stats = <String, Map<AttendanceStatus, int>>{};

      for (final record in attendance) {
        if (!stats.containsKey(record.subject)) {
          stats[record.subject] = {
            AttendanceStatus.present: 0,
            AttendanceStatus.absent: 0,
            AttendanceStatus.late: 0,
            AttendanceStatus.excused: 0,
          };
        }
        stats[record.subject]![record.status] =
            (stats[record.subject]![record.status] ?? 0) + 1;
      }

      return stats;
    });
