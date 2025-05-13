// lib/features/teacher/providers/assignment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/assignment.dart';
import '../../../core/auth_service.dart'; // Для получения ID текущего учителя

final assignmentServiceProvider = Provider(
  (ref) => AssignmentService(FirebaseFirestore.instance, ref),
);

// Провайдер для стрима заданий текущего учителя
final teacherAssignmentsProvider = StreamProvider.autoDispose<List<Assignment>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    final teacherId = authState.valueOrNull?.id;

    if (teacherId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('assignments')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return Assignment.fromJson(data..['id'] = doc.id);
              }).toList(),
        );
  },
);

class AssignmentService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  AssignmentService(this._firestore, this._ref);

  Future<DocumentReference> addAssignment(Assignment assignment) async {
    final teacher = _ref.read(authStateProvider).valueOrNull;
    if (teacher == null) throw Exception('Пользователь не авторизован');

    final assignmentWithTeacher = assignment.copyWith(
      teacherId: teacher.id,
      teacherName: teacher.shortName, // или fullName
      createdAt: DateTime.now(), // Устанавливаем время создания здесь
    );
    return _firestore
        .collection('assignments')
        .add(assignmentWithTeacher.toJson());
  }

  Future<void> updateAssignment(Assignment assignment) async {
    if (assignment.id == null) {
      throw Exception('ID задания не указан для обновления');
    }
    // Убедимся, что createdAt не перезаписывается при обновлении, если оно не менялось
    final Map<String, dynamic> dataToUpdate = assignment.toJson();
    dataToUpdate.remove('createdAt'); // Не обновляем createdAt, если не нужно

    await _firestore
        .collection('assignments')
        .doc(assignment.id)
        .update(dataToUpdate);
  }

  Future<void> deleteAssignment(String assignmentId) async {
    // TODO: Подумать об удалении связанных файлов из Firebase Storage
    await _firestore.collection('assignments').doc(assignmentId).delete();
  }

  // TODO: Методы для загрузки/удаления файлов в Firebase Storage
  // Future<AssignmentAttachment> uploadFile(File file, String assignmentId) async { ... }
  // Future<void> deleteFile(String assignmentId, String fileName) async { ... }
}
