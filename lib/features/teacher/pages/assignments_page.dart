import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/assignment.dart';
import '../../../providers/assignment_provider.dart';
import 'assignment_edit_page.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssignmentEditPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(child: Text('Нет заданий'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return Card(
                child: ListTile(
                  title: Text(assignment.title),
                  subtitle: Text(assignment.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Удалить задание?'),
                              content: const Text(
                                'Это действие нельзя будет отменить.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                      );

                      if (confirmed == true && mounted) {
                        await ref
                            .read(assignmentServiceProvider)
                            .deleteAssignment(assignment.id);
                      }
                    },
                  ),
                  onTap: () async {
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AssignmentEditPage(assignment: assignment),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ошибка загрузки заданий'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(assignmentsProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
