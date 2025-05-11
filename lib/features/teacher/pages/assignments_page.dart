import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment.dart';
import '../models/group.dart';
import '../services/firebase_service.dart';
import '../providers/teacher_providers.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  Group? selectedGroup;
  String title = '';
  String description = '';
  DateTime dueDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.read(firebaseServiceProvider);
    final teacherId = ref.read(teacherIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Домашние задания')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<List<Group>>(
              future: firebaseService.getGroups(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DropdownButton<Group>(
                  value: selectedGroup,
                  hint: Text('Выбери группу'),
                  onChanged: (g) => setState(() => selectedGroup = g),
                  items: snapshot.data!
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                      .toList(),
                );
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Тема задания'),
              onChanged: (val) => setState(() => title = val),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Описание'),
              onChanged: (val) => setState(() => description = val),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedGroup == null) return;
                final assignment = Assignment(
                  id: '',
                  teacherId: teacherId,
                  groupId: selectedGroup!.id,
                  title: title,
                  description: description,
                  dueDate: dueDate,
                );
                await firebaseService.addAssignment(assignment);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Задание добавлено')));
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
