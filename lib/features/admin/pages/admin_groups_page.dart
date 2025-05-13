import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/group.dart'; // Ваша модель Group
import '../../../models/user.dart' as app_user;
import '../providers/admin_groups_provider.dart'; // Провайдеры для групп
import '../widgets/group_form_dialog.dart';
import 'admin_groups_page.dart';

// Получение всех групп
final allGroupsProvider = StreamProvider.autoDispose<List<Group>>((ref) {
  return FirebaseFirestore.instance
      .collection('groups')
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) {
                  try {
                    return Group.fromJson({...doc.data(), 'id': doc.id});
                  } catch (e) {
                    print('Ошибка парсинга группы ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<Group>()
                .toList(),
      );
});

// Сервис управления группами
final groupManagementServiceProvider = Provider(
  (ref) => GroupManagementService(FirebaseFirestore.instance),
);

// Получение всех учителей
final teacherListProvider = FutureProvider.autoDispose<List<app_user.User>>((
  ref,
) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();
  return snapshot.docs
      .map((doc) => app_user.User.fromJson({...doc.data(), 'id': doc.id}))
      .toList();
});

// Количество студентов в группе
final studentsInGroupCountProvider = FutureProvider.family
    .autoDispose<int, String>((ref, groupId) async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'student')
              .where('groupId', isEqualTo: groupId)
              .get();
      return snapshot.size;
    });

// Пример сервиса (реализуйте методы по необходимости)
class GroupManagementService {
  final FirebaseFirestore _firestore;
  GroupManagementService(this._firestore);

  Future<void> addGroup(Group group) async {
    await _firestore.collection('groups').add(group.toJson());
  }

  Future<void> updateGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).update(group.toJson());
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }
}

class AdminGroupsPage extends ConsumerWidget {
  const AdminGroupsPage({super.key});

  Future<void> _openGroupForm(
    BuildContext context,
    WidgetRef ref, [
    Group? group,
  ]) async {
    final result = await showDialog<Group>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => GroupFormDialog(
            group: group,
            onSave: (newGroup) async {
              if (group == null) {
                await ref
                    .read(groupManagementServiceProvider)
                    .addGroup(newGroup);
              } else {
                await ref
                    .read(groupManagementServiceProvider)
                    .updateGroup(newGroup);
              }
            },
          ),
    );
    if (result != null) {
      ref.invalidate(allGroupsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Группа ${group == null ? "создана" : "обновлена"} успешно!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Подтвердить удаление'),
            content: Text(
              'Вы уверены, что хотите удалить группу "${group.name}"? Это действие необратимо.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
    if (confirm == true && group.id != null) {
      try {
        await ref.read(groupManagementServiceProvider).deleteGroup(group.id!);
        ref.invalidate(allGroupsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Группа "${group.name}" удалена'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления группы: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(allGroupsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: groupsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) => Center(
                      child: Text(
                        'Ошибка загрузки групп: $err',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 60,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Группы еще не созданы.',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Создать первую группу'),
                            onPressed: () => _openGroupForm(context, ref),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            child: Material(
                              elevation: 0.5,
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              color: theme.cardColor,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                                ),
                                dataRowMinHeight: 52,
                                dataRowMaxHeight: 60,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Название',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Куратор',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Курс',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Специальность',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Студенты',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Действия',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows:
                                    groups.map((group) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              group.name,
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              group.teacherName ??
                                                  'Не назначен',
                                            ),
                                          ),
                                          DataCell(
                                            Text(group.course.toString()),
                                          ),
                                          DataCell(
                                            Text(
                                              group.specialty,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DataCell(
                                            Consumer(
                                              builder: (context, ref, _) {
                                                final studentsCount = ref.watch(
                                                  studentsInGroupCountProvider(
                                                    group.id!,
                                                  ),
                                                );
                                                return studentsCount.when(
                                                  data:
                                                      (count) => Text(
                                                        count.toString(),
                                                      ),
                                                  loading:
                                                      () => const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                  error:
                                                      (_, __) => const Text(
                                                        '-',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit_outlined,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                    size: 20,
                                                  ),
                                                  tooltip: 'Редактировать',
                                                  onPressed:
                                                      () => _openGroupForm(
                                                        context,
                                                        ref,
                                                        group,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.people_alt_outlined,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .secondary,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      'Управление студентами',
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'TODO: Управление студентами группы ${group.name}',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color:
                                                        theme.colorScheme.error,
                                                    size: 20,
                                                  ),
                                                  tooltip: 'Удалить',
                                                  onPressed:
                                                      () => _deleteGroup(
                                                        context,
                                                        ref,
                                                        group,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ).animate().fadeIn(duration: 300.ms),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Создать группу'),
            onPressed: () => _openGroupForm(context, ref),
          )
          .animate()
          .slideX(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic)
          .fadeIn(delay: 200.ms),
    );
  }
}
