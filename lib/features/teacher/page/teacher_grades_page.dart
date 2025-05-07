import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class TeacherGradesPage extends ConsumerWidget {
  const TeacherGradesPage({super.key});
  
  ProviderListenable get groupsProvider {
    // TODO: implement groupsProvider
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Выставить оценки')),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (groupList) => ListView.builder(
          itemCount: groupList.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(groupList[i].name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/teacher/grades/group',
                arguments: groupList[i],
              );
            },
          ),
        ),
      ),
    );
  }
}

