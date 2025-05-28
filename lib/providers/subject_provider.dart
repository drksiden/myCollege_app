import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../services/subject_service.dart';
import '../core/auth_service.dart';
import '../features/student/providers/schedule_provider.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../services/teacher_service.dart';
import '../models/teacher.dart';

final subjectServiceProvider = Provider((ref) => SubjectService());
final userServiceProvider = Provider((ref) => UserService());
final teacherServiceProvider = Provider((ref) => TeacherService());

// Провайдер для всех предметов
final subjectsProvider = StreamProvider.autoDispose<List<Subject>>((ref) {
  final subjectService = ref.watch(subjectServiceProvider);
  return subjectService.getAllSubjects();
});

// Провайдер для предметов текущего преподавателя
final teacherSubjectsProvider = StreamProvider.autoDispose<List<Subject>>((
  ref,
) {
  final subjectService = ref.watch(subjectServiceProvider);
  return subjectService.getSubjectsByTeacher(
    ref.watch(authStateProvider).valueOrNull?.id ?? '',
  );
});

// Провайдер для предметов текущей группы
final groupSubjectsProvider = StreamProvider.autoDispose<List<Subject>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.groupId == null) return Stream.value([]);

  final subjectService = ref.watch(subjectServiceProvider);
  return subjectService.getSubjectsByGroup(user!.groupId!);
});

// Провайдер для получения предметов по списку ID из расписания
final scheduleSubjectsProvider =
    FutureProvider.autoDispose<Map<String, Subject>>((ref) async {
      final scheduleAsync = await ref.watch(scheduleProvider.future);
      if (scheduleAsync.isEmpty) return {};
      final subjectIds =
          scheduleAsync.map((entry) => entry.subjectId).toSet().toList();
      if (subjectIds.isEmpty) return {};
      final subjectService = ref.watch(subjectServiceProvider);
      return await subjectService.getSubjectsByIds(subjectIds);
    });

// Кэш для хранения загруженных предметов
final _subjectsCache = <String, Subject>{};

// Провайдер для получения предметов по списку ID
final subjectsMapProvider = FutureProvider.autoDispose
    .family<Map<String, Subject>, List<String>>((ref, ids) async {
      if (ids.isEmpty) return {};
      final subjectService = ref.watch(subjectServiceProvider);
      return subjectService.getSubjectsByIds(ids);
    });

// Провайдер для получения имени учителя по teacherId
final teacherNameProvider = FutureProvider.family<String, String>((
  ref,
  teacherId,
) async {
  if (teacherId.isEmpty) return 'Не указан';
  final teacherService = ref.read(teacherServiceProvider);
  final userService = ref.read(userServiceProvider);
  final teacher = await teacherService.getTeacherById(teacherId);
  if (teacher == null || teacher.userId.isEmpty) return 'Не указан';
  final user = await userService.getUserById(teacher.userId);
  return user?.fullName ?? 'Не указан';
});
