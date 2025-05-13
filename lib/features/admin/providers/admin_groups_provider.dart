import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/group.dart'; // Ваша модель Group
// import 'admin_management_service.dart'; // Если будет общий сервис

// Провайдер для получения всех групп
final allGroupsProvider = StreamProvider.autoDispose<List<Group>>((ref) {
  // TODO: Добавить orderBy, если нужно (например, по имени группы)
  return FirebaseFirestore.instance
      .collection('groups')
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final data = doc.data();
              // Убедимся, что ID документа добавляется в модель, если fromJson его не ожидает напрямую
              return Group.fromJson(data..['id'] = doc.id);
            }).toList(),
      );
});

// TODO: Провайдер для сервиса управления группами (CRUD)
// final groupManagementServiceProvider = Provider((ref) => GroupManagementService(FirebaseFirestore.instance, ref));

// class GroupManagementService {
//   final FirebaseFirestore _firestore;
//   final Ref _ref;
//   GroupManagementService(this._firestore, this._ref);

//   Future<void> addGroup(Group group) async { /* ... */ }
//   Future<void> updateGroup(Group group) async { /* ... */ }
//   Future<void> deleteGroup(String groupId) async { /* ... */ }
//   Future<void> assignCurator(String groupId, String teacherId) async { /* ... */ }
//   Future<void> addStudentToGroup(String groupId, String studentId) async { /* ... */ }
//   Future<void> removeStudentFromGroup(String groupId, String studentId) async { /* ... */ }
// }

// TODO: Провайдер для списка учителей (для выбора куратора)
// final teacherListProvider = FutureProvider.autoDispose<List<app_user.User>>((ref) async {
//   final snapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get();
//   return snapshot.docs.map((doc) => app_user.User.fromJson(doc.data()..['id'] = doc.id)).toList();
// });

// TODO: Провайдер для списка студентов (для добавления в группу, возможно, без группы)
// final unassignedStudentsProvider = FutureProvider.autoDispose<List<app_user.User>>((ref) async {
//    final snapshot = await FirebaseFirestore.instance.collection('users')
//        .where('role', isEqualTo: 'student')
//        .where('groupId', isNull: true) // Или 'groupId', isEqualTo: ''
//        .get();
//    return snapshot.docs.map((doc) => app_user.User.fromJson(doc.data()..['id'] = doc.id)).toList();
// });
