import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/teacher_goups_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/group.dart'; // ИСПРАВЛЕНО: используем основную модель Group
import '../models/grade.dart';
import '../models/student.dart';
import '../providers/teacher_providers.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  Group? selectedGroup;
  Student? selectedStudent;
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

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.read(firebaseServiceProvider);
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final teacherName = ref.read(teacherNameProvider);

    // Используем новый провайдер для групп преподавателя
    final teacherGroupsAsync = ref.watch(teacherGroupsProvider(teacherId));

    return Scaffold(
      appBar: AppBar(title: const Text('Выставить оценку')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор группы - теперь только группы преподавателя
            teacherGroupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ошибка загрузки групп: $error',
                            style: const TextStyle(color: Colors.red),
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
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'У вас нет назначенных групп. Обратитесь к администратору.',
                            style: TextStyle(color: Colors.orange),
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
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Group>(
                      decoration: const InputDecoration(
                        labelText: 'Группа',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      isExpanded: true,
                      value: selectedGroup,
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
              FutureBuilder<List<Student>>(
                future: firebaseService.getStudentsByGroup(selectedGroup!.id),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ошибка загрузки студентов: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('В этой группе нет студентов'),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выберите студента (${students.length} ${_getStudentCountText(students.length)}):',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Student>(
                        decoration: const InputDecoration(
                          labelText: 'Студент',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        isExpanded: true,
                        value: selectedStudent,
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
                                      s.name,
                                      overflow: TextOverflow.ellipsis,
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
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Предмет',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    isExpanded: true,
                    value: selectedSubject,
                    onChanged: (val) => setState(() => selectedSubject = val),
                    items:
                        subjects
                            .map(
                              (subj) => DropdownMenuItem(
                                value: subj,
                                child: Text(subj),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: score.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '$score',
                      onChanged: (val) => setState(() => score = val.toInt()),
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
                                      const SnackBar(
                                        content: Text(
                                          'Выберите группу, студента и предмет',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);
                                  try {
                                    final grade = Grade(
                                      id: '',
                                      studentId: selectedStudent!.id,
                                      teacherId: teacherId,
                                      teacherName: teacherName,
                                      groupId: selectedGroup!.id,
                                      subject: selectedSubject!,
                                      score: score,
                                      timestamp: DateTime.now(),
                                    );
                                    await firebaseService.addGrade(grade);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Оценка успешно поставлена',
                                          ),
                                          backgroundColor: Colors.green,
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
                                          backgroundColor: Colors.red,
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
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.grade),
                        label: const Text('Поставить оценку'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
