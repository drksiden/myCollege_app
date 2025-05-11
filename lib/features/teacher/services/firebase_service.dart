import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session.dart';
import '../models/group.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/assignment.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Class Sessions
  Stream<List<ClassSession>> getTeacherSessions(String teacherId) {
    return _db
        .collection('class_sessions')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassSession.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Groups
  Future<List<Group>> getGroups() async {
    final snapshot = await _db.collection('groups').get();
    return snapshot.docs
        .map((doc) => Group.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Students in group
  Future<List<Student>> getStudentsByGroup(String groupId) async {
    final snapshot = await _db
        .collection('students')
        .where('groupId', isEqualTo: groupId)
        .get();
    return snapshot.docs
        .map((doc) => Student.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Grades
  Future<void> addGrade(Grade grade) async {
    await _db.collection('grades').add(grade.toMap());
  }

  // Assignments
  Future<void> addAssignment(Assignment assignment) async {
    await _db.collection('assignments').add(assignment.toMap());
  }

  Stream<List<Assignment>> getAssignmentsByTeacher(String teacherId) {
    return _db
        .collection('assignments')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Assignment.fromMap(doc.data(), doc.id))
            .toList());
  }
}
