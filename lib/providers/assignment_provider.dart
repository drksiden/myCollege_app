import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment.dart';
import '../services/assignment_service.dart';

final assignmentServiceProvider = Provider((ref) => AssignmentService());

// Провайдер для получения всех заданий
final assignmentsProvider = StreamProvider.autoDispose<List<Assignment>>((ref) {
  final assignmentService = ref.watch(assignmentServiceProvider);
  return assignmentService.getAssignments();
});

// Провайдер для получения заданий по groupId (для учителя)
final assignmentsByGroupProvider = StreamProvider.family.autoDispose<List<Assignment>, String>((ref, groupId) {
  final assignmentService = ref.watch(assignmentServiceProvider);
  return assignmentService.getAssignmentsByGroup(groupId);
});