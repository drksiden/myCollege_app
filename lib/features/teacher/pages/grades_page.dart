// lib/features/teacher/pages/grades_page.dart (ИСПРАВЛЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/teacher_goups_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/group.dart';
import '../../../models/user.dart'
    as app_user; // Используем основную модель User
import '../models/grade.dart';
import '../providers/teacher_providers.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  Group? selectedGroup;
  app_user.User? selectedStudent; // Используем app_user.User вместо Student
  String? selectedSubject;
  int score = 0;
  bool isLoading = false;

  // Список предметов - можно расширить или получать из базы
  final List<String> subjects = [
    'Математика',
    'Физика',
    'Химия',
    'История',
    'Литература',
    'Программирование',
    'Базы данных',
    'Веб-разработка',
    'Английский язык',
    'Программное обеспечение',
  ];

  // ИСПРАВЛЕННЫЙ метод для получения студентов группы
  Future<List<app_user.User>> _getStudentsByGroup(String groupId) async {
    try {
      print('DEBUG: Getting students for group: $groupId');

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users') // Правильная коллекция
              .where('groupId', isEqualTo: groupId)
              .where('role', isEqualTo: 'student')
              .where('status', isEqualTo: 'active') // Только активные студенты
              .get();

      print('DEBUG: Found ${snapshot.docs.length} students');

      final students =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return app_user.User.fromJson({...data, 'uid': doc.id});
          }).toList();

      // Сортируем по фамилии и имени
      students.sort((a, b) {
        final comparison = a.lastName.compareTo(b.lastName);
        if (comparison != 0) return comparison;
        return a.firstName.compareTo(b.firstName);
      });

      return students;
    } catch (e) {
      print('DEBUG: Error getting students: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final teacherName = ref.read(teacherNameProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ОТЛАДКА: проверяем данные (можно удалить после исправления)
    print('DEBUG: Current teacher ID: $teacherId');
    // Раскомментируйте эти строки для отладки:
    // DebugHelper.checkUserData();
    // DebugHelper.checkGroupData();
    // DebugHelper.checkScheduleData(teacherId);

    // Используем провайдер для групп преподавателя
    final teacherGroupsAsync = ref.watch(teacherGroupsProvider(teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выставить оценку'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор группы
            teacherGroupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ошибка загрузки групп: $error',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
              data: (groups) {
                if (groups.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'У вас нет назначенных групп. Обратитесь к администратору.',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выберите группу (${groups.length} ${_getGroupCountText(groups.length)}):',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Group>(
                      decoration: InputDecoration(
                        labelText: 'Группа',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.group,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      isExpanded: true,
                      value: selectedGroup,
                      dropdownColor: colorScheme.surface,
                      style: TextStyle(color: colorScheme.onSurface),
                      onChanged: (g) {
                        setState(() {
                          selectedGroup = g;
                          selectedStudent = null;
                          selectedSubject = null;
                        });
                      },
                      items:
                          groups
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(
                                    '${g.name} - ${g.specialization} ${g.year} курс',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Выбор студента
            if (selectedGroup != null)
              FutureBuilder<List<app_user.User>>(
                future: _getStudentsByGroup(selectedGroup!.id),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ошибка загрузки студентов: ${snapshot.error}',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }

                  final students = snapshot.data ?? [];
                  print('DEBUG: UI received ${students.length} students');

                  if (students.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'В группе "${selectedGroup!.name}" нет активных студентов',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выберите студента (${students.length} ${_getStudentCountText(students.length)}):',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<app_user.User>(
                        decoration: InputDecoration(
                          labelText: 'Студент',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        isExpanded: true,
                        value: selectedStudent,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        onChanged: (s) {
                          setState(() {
                            selectedStudent = s;
                            selectedSubject = null;
                          });
                        },
                        items:
                            students
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),

            // Выбор предмета
            if (selectedStudent != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите предмет:',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Предмет',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.book, color: colorScheme.primary),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    isExpanded: true,
                    value: selectedSubject,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: (val) => setState(() => selectedSubject = val),
                    items:
                        subjects
                            .map(
                              (subj) => DropdownMenuItem(
                                value: subj,
                                child: Text(
                                  subj,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Выставление оценки
            if (selectedSubject != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Оценка: $score',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.outline.withOpacity(
                          0.3,
                        ),
                        thumbColor: colorScheme.primary,
                        overlayColor: colorScheme.primary.withOpacity(0.2),
                        valueIndicatorColor: colorScheme.primary,
                        valueIndicatorTextStyle: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: score.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '$score',
                        onChanged: (val) => setState(() => score = val.toInt()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  if (selectedGroup == null ||
                                      selectedStudent == null ||
                                      selectedSubject == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Выберите группу, студента и предмет',
                                        ),
                                        backgroundColor: colorScheme.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    // ИСПРАВЛЕННОЕ создание оценки
                                    await FirebaseFirestore.instance
                                        .collection('grades')
                                        .add({
                                          'studentId': selectedStudent!.uid,
                                          'teacherId': teacherId,
                                          'teacherName': teacherName,
                                          'groupId': selectedGroup!.id,
                                          'subject': selectedSubject!,
                                          'score': score,
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                        });

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Оценка успешно поставлена',
                                          ),
                                          backgroundColor: colorScheme.primary,
                                        ),
                                      );
                                      // Сбрасываем форму
                                      setState(() {
                                        selectedStudent = null;
                                        selectedSubject = null;
                                        score = 0;
                                      });
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Ошибка: $e'),
                                          backgroundColor: colorScheme.error,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                        icon:
                            isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                                : Icon(
                                  Icons.grade,
                                  color: colorScheme.onPrimary,
                                ),
                        label: Text(
                          'Поставить оценку',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getGroupCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'группа';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'группы';
    } else {
      return 'групп';
    }
  }

  String _getStudentCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'студент';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'студента';
    } else {
      return 'студентов';
    }
  }
}
