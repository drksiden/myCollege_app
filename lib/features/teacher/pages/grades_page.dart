import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grade.dart';
import '../models/student.dart';
import '../models/group.dart';
import '../providers/teacher_providers.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  Group? selectedGroup;
  Student? selectedStudent;
  String? selectedSubject; // Добавляем для выбора предмета
  int score = 0;
  bool isLoading = false;

  // Для простоты пока фиксированный список предметов.
  // Если у тебя предметы из базы, то можно заменить на загрузку из firebaseService
  final List<String> subjects = [
    'Математика',
    'Физика',
    'Химия',
    'История',
    'Литература',
  ];

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.read(firebaseServiceProvider);
    final teacherId = ref.read(teacherIdProvider);
    final teacherName = ref.read(teacherNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выставить оценку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Group>>(
              future: firebaseService.getGroups(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки групп'));
                }
                final groups = snapshot.data ?? [];
                return DropdownButton<Group>(
                  isExpanded: true,
                  hint: const Text('Выбери группу'),
                  value: selectedGroup,
                  onChanged: (g) {
                    setState(() {
                      selectedGroup = g;
                      selectedStudent = null;
                      selectedSubject = null;
                    });
                  },
                  items: groups
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.name),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            if (selectedGroup != null)
              FutureBuilder<List<Student>>(
                future: firebaseService.getStudentsByGroup(selectedGroup!.id),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка загрузки учеников'));
                  }
                  final students = snapshot.data ?? [];
                  return DropdownButton<Student>(
                    isExpanded: true,
                    hint: const Text('Выбери ученика'),
                    value: selectedStudent,
                    onChanged: (s) {
                      setState(() {
                        selectedStudent = s;
                        selectedSubject = null;
                      });
                    },
                    items: students
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            ))
                        .toList(),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Выбор предмета - показываем, если выбран ученик
            if (selectedStudent != null)
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Выбери предмет'),
                value: selectedSubject,
                onChanged: (val) => setState(() => selectedSubject = val),
                items: subjects
                    .map((subj) => DropdownMenuItem(
                          value: subj,
                          child: Text(subj),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),

            if (selectedSubject != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Оценка: $score', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: score.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$score',
                    onChanged: (val) => setState(() => score = val.toInt()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (selectedGroup == null ||
                                  selectedStudent == null ||
                                  selectedSubject == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Выберите группу, ученика и предмет')),
                                );
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                final grade = Grade(
                                  id: '',
                                  studentId: selectedStudent!.id,
                                  teacherId: teacherId,
                                  teacherName: teacherName,
                                  groupId: selectedGroup!.id,
                                  subject: selectedSubject!, // теперь из выбора
                                  score: score,
                                  timestamp: DateTime.now(),
                                );
                                await firebaseService.addGrade(grade);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Оценка успешно поставлена')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка: $e')),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Поставить оценку'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}