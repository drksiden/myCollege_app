import 'lesson.dart';

class ScheduleDay {
  final String dayName; // Название дня недели ('Понедельник', ...)
  final List<Lesson> lessons;

  ScheduleDay({required this.dayName, required this.lessons});
}
