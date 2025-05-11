import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/grade.dart';
import '../models/student.dart';
import '../models/group.dart';
import '../providers/teacher_providers.dart';

class GradesPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  Group? selectedGroup;
  Student? selectedStudent;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.read(firebaseServiceProvider);
    final teacherId = ref.read(teacherIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Оценки')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<List<Group>>(
              future: firebaseService.getGroups(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final groups = snapshot.data!;
                return DropdownButton<Group>(
                  hint: Text('Выбери группу'),
                  value: selectedGroup,
                  onChanged: (g) => setState(() => selectedGroup = g),
                  items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                );
              },
            ),
            if (selectedGroup != null)
              FutureBuilder<List<Student>>(
                future: firebaseService.getStudentsByGroup(selectedGroup!.id),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final students = snapshot.data!;
                  return DropdownButton<Student>(
                    hint: Text('Выбери ученика'),
                    value: selectedStudent,
                    onChanged: (s) => setState(() => selectedStudent = s),
                    items: students
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                  );
                },
              ),
            if (selectedStudent != null)
              Column(
                children: [
                  Slider(
                    value: score.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$score',
                    onChanged: (val) => setState(() => score = val.toInt()),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final grade = Grade(
                        id: '',
                        studentId: selectedStudent!.id,
                        teacherId: teacherId,
                        groupId: selectedGroup!.id,
                        score: score,
                        timestamp: DateTime.now(),
                      );
                      await firebaseService.addGrade(grade);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Оценка поставлена')));
                    },
                    child: Text('Поставить оценку'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
