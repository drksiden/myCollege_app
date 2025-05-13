import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final usersCountProvider = StreamProvider<int>((ref) async* {
  final snapshots = FirebaseFirestore.instance.collection('users').snapshots();
  await for (final snap in snapshots) {
    yield snap.docs.length;
  }
});

final groupsCountProvider = StreamProvider<int>((ref) async* {
  final snapshots = FirebaseFirestore.instance.collection('groups').snapshots();
  await for (final snap in snapshots) {
    yield snap.docs.length;
  }
});

final subjectsCountProvider = StreamProvider<int>((ref) async* {
  final snapshots =
      FirebaseFirestore.instance.collection('subjects').snapshots();
  await for (final snap in snapshots) {
    yield snap.docs.length;
  }
});

final assignmentsCountProvider = StreamProvider<int>((ref) async* {
  final snapshots =
      FirebaseFirestore.instance.collection('assignments').snapshots();
  await for (final snap in snapshots) {
    yield snap.docs.length;
  }
});
