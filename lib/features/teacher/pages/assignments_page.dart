import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/assignment_provider.dart';
import '../../../providers/group_provider.dart';
import 'assignment_edit_page.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  final bool showAppBar;
  const AssignmentsPage({super.key, this.showAppBar = true});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  String? selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(allGroupsProvider);
    final assignmentsAsync = selectedGroupId != null
        ? ref.watch(assignmentsByGroupProvider(selectedGroupId!))
        : null;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Задания'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (!mounted || selectedGroupId == null) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentEditPage(
                          groupId: selectedGroupId!,
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return const Text('Нет доступных групп');
                }
                return DropdownButton<String>(
                  hint: const Text('Выберите группу'),
                  value: selectedGroupId,
                  isExpanded: true,
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroupId = value;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Ошибка загрузки групп'),
            ),
          ),
          Expanded(
            child: selectedGroupId == null
                ? const Center(child: Text('Выберите группу'))
                : assignmentsAsync!.when(
                    data: (assignments) {
                      if (assignments.isEmpty) {
                        return const Center(child: Text('Нет заданий для этой группы'));
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
                                    builder: (context) => AlertDialog(
                                      title: const Text('Удалить задание?'),
                                      content: const Text('Это действие нельзя будет отменить.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
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
                                    builder: (context) =>
                                        AssignmentEditPage(assignment: assignment, groupId: selectedGroupId),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ошибка загрузки заданий: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(assignmentsByGroupProvider(selectedGroupId!)),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}