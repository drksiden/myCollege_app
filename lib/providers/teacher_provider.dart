import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final teacherNameByIdProvider = FutureProvider.family<String, String>((
  ref,
  teacherId,
) async {
  if (teacherId.isEmpty) return 'Не указан';

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(teacherId).get();

  if (!doc.exists) return 'Преподаватель не найден';

  final data = doc.data() as Map<String, dynamic>;
  return '${data['lastName']} ${data['firstName']} ${data['middleName']}';
});
