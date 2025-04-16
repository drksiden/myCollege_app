import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/lesson.dart'; // Импорт Lesson
import '../models/schedule_day.dart';

// Данные для GradesScreen
final List<Map<String, dynamic>> mockGrades = [
  {'subject': 'Математика', 'score': 90, 'date': '2025-03-01'},
  {'subject': 'Математика', 'score': 85, 'date': '2025-03-15'},
  {'subject': 'Физика', 'score': 70, 'date': '2025-03-10'},
  {'subject': 'Физика', 'score': 75, 'date': '2025-04-01'},
  {'subject': 'Информатика', 'score': 100, 'date': '2025-03-05'},
  {'subject': 'Информатика', 'score': 98, 'date': '2025-04-03'},
  // Добавьте больше оценок или предметов по желанию
  {'subject': 'История', 'score': 65, 'date': '2025-04-10'},
  {'subject': 'Английский язык', 'score': 88, 'date': '2025-04-12'},
];

// Mock данные для ScheduleScreen, используя модели
final List<ScheduleDay> mockSchedule = [
  ScheduleDay(
    dayName: 'Понедельник',
    lessons: [
      Lesson(
        subject: 'Математика',
        teacher: 'А. Тлеуов',
        timeRange: '08:00 - 09:30',
        room: 'Каб. 201',
        icon: Icons.calculate_outlined,
      ),
      Lesson(
        subject: 'Физика',
        teacher: 'С. Нурпеисов',
        timeRange: '09:40 - 11:10',
        room: 'Лекц. зал 1',
        icon: Icons.science_outlined,
      ),
      Lesson(
        subject: 'Программирование',
        teacher: 'М. Кабылова',
        timeRange: '11:20 - 12:50',
        room: 'Комп. класс 3',
        icon: Icons.computer_outlined,
      ),
    ],
  ),
  ScheduleDay(
    dayName: 'Вторник',
    lessons: [
      Lesson(
        subject: 'Информатика',
        teacher: 'М. Кабылова',
        timeRange: '08:00 - 09:30',
        room: 'Комп. класс 3',
        icon: Icons.computer_outlined,
      ),
      Lesson(
        subject: 'Английский язык',
        teacher: 'Ж. Тойганбаева',
        timeRange: '09:40 - 11:10',
        room: 'Каб. 305',
        icon: Icons.language_outlined,
      ),
    ],
  ),
  ScheduleDay(
    dayName: 'Среда', // Сегодня (16 апреля 2025 - Среда)
    lessons: [
      Lesson(
        subject: 'История Казахстана',
        teacher: 'Б. Жумагалиева',
        timeRange: '08:00 - 09:30',
        room: 'Каб. 102',
        icon: Icons.history_edu_outlined,
      ),
      // Добавим пару, которая идет прямо сейчас (примерно 21:30) - нереалистично, но для теста
      Lesson(
        subject: 'Веб-дизайн (Вечер.)',
        teacher: 'А. Иванов',
        timeRange: '21:00 - 22:30',
        room: 'Онлайн',
        icon: Icons.web_outlined,
      ),
    ],
  ),
  ScheduleDay(
    dayName: 'Четверг',
    lessons: [
      Lesson(
        subject: 'Математика',
        teacher: 'А. Тлеуов',
        timeRange: '08:00 - 09:30',
        room: 'Каб. 201',
        icon: Icons.calculate_outlined,
      ),
      Lesson(
        subject: 'Базы данных',
        teacher: 'Р. Ахметов',
        timeRange: '09:40 - 11:10',
        room: 'Комп. класс 1',
        icon: Icons.storage_outlined,
      ),
    ],
  ),
  ScheduleDay(
    dayName: 'Пятница',
    lessons: [
      Lesson(
        subject: 'Физкультура',
        teacher: 'А. Айтмуратов',
        timeRange: '10:00 - 11:30',
        room: 'Спортзал',
        icon: Icons.fitness_center_outlined,
      ),
      Lesson(
        subject: 'Английский язык',
        teacher: 'Ж. Тойганбаева',
        timeRange: '11:40 - 13:10',
        room: 'Каб. 305',
        icon: Icons.language_outlined,
      ),
    ],
  ),
  ScheduleDay(
    dayName: 'Суббота', // Пример дня без пар
    lessons: [],
  ),
];

// Данные для ActivitiesScreen
final List<Map<String, dynamic>> mockActivities = [
  {
    'title': 'Олимпиада по математике',
    'description': 'Приглашаем студентов 1-4 курсов принять участие.',
    'date':
        '2025-04-18', // Дата в прошлом или будущем? Проверить относительно 16 апр 2025
    'type': 'academic',
  },
  {
    'title': 'Навруз – Весенний праздник',
    'description': 'Будет концерт, угощения и традиционные игры!',
    'date': '2025-03-21', // Прошедшее
    'type': 'event',
  },
  {
    'title': 'Ярмарка клубов',
    'description': 'Познакомься с кружками и секциями университета.',
    'date': '2025-04-25', // Будущее
    'type': 'social',
  },
  {
    'title': 'День открытых дверей',
    'description': 'Расскажем абитуриентам о нашем колледже.',
    'date': '2025-05-15', // Будущее
    'type': 'social',
  },
  {
    'title': 'Конференция "IT Trends 2025"',
    'description': 'Доклады ведущих специалистов отрасли.',
    'date': '2025-04-17', // Сегодняшний или завтрашний день, смотря по времени
    'type': 'academic',
  },
];

// Mock данные для ProfileScreen, используя модель UserProfile
final UserProfile mockUserProfile = UserProfile(
  id: 'mock_user_123', // Пример ID
  name: 'Нурдаулет Сабырбекулы',
  studentId: '202500123',
  age: 20,
  course: 3,
  specialty: 'Информационные системы', // Немного изменил для примера
  group: 'ИС-321', // Немного изменил для примера
  profileImageUrl: '', // Оставляем пустым для placeholder'а
  email: 'n.sabyrbekuly@college.kz', // Пример email
  phone: '+7 707 123 4567', // Пример телефона
);
