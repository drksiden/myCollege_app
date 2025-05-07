
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherTasksPage extends ConsumerWidget {
  const TeacherTasksPage({super.key});
  
  ProviderListenable get teacherTasksProvider {
    // TODO: implement teacherTasksProvider
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(teacherTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Задания')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/teacher/tasks/new'),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (tasks) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (_, i) => Card(
            child: ListTile(
              title: Text(tasks[i].title),
              subtitle: Text(tasks[i].description),
            ),
          ),
        ),
      ),
    );
  }
}
