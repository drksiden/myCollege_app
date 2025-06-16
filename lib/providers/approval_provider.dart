import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/approval.dart';
import '../core/auth_service.dart';

final userApprovalProvider = StreamProvider.autoDispose<Approval?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('approvals')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          return null;
        }

        return Approval.fromJson(doc.data()!);
      });
});
