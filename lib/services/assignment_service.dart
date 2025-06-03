import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment.dart';

class AssignmentService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Assignment>> getAssignments() {
    return _firestore
        .collection('assignments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Assignment.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Assignment>> getAssignmentsByGroup(String groupId) {
    return _firestore
        .collection('assignments')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Assignment.fromJson(doc.data()))
            .toList());
  }

  Future<void> addAssignment(Assignment assignment) async {
    final docRef = _firestore.collection('assignments').doc();
    final newAssignment = assignment.copyWith(id: docRef.id);
    await docRef.set(newAssignment.toJson());
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await _firestore
        .collection('assignments')
        .doc(assignment.id)
        .update(assignment.toJson());
  }

  Future<void> deleteAssignment(String id) async {
    await _firestore.collection('assignments').doc(id).delete();
  }
}