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
  final lastName = data['lastName'] ?? '';
  final firstName = data['firstName'] ?? '';
  final middleName = data['middleName'];
  // Формируем ФИО без null и лишних пробелов
  final fio =
      [
        lastName,
        firstName,
        if (middleName != null && middleName.toString().trim().isNotEmpty)
          middleName,
      ].join(' ').replaceAll(RegExp(r' +'), ' ').trim();
  return fio.isEmpty ? 'Не указан' : fio;
});
