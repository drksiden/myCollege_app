import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  final _firestore = FirebaseFirestore.instance;

  Future<Group?> getGroup(String groupId) async {
    print('DEBUG: GroupService: Getting group with ID: $groupId');
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) {
        print('DEBUG: GroupService: Group document does not exist');
        return null;
      }

      final data = doc.data()!;
      print('DEBUG: GroupService: Group data: $data');

      final groupData = {...data, 'id': doc.id};

      final group = Group.fromJson(groupData);
      print('DEBUG: GroupService: Created Group object: $group');
      return group;
    } catch (e, stackTrace) {
      print('DEBUG: GroupService: Error getting group: $e');
      print('DEBUG: GroupService: Stack trace: $stackTrace');
      return null;
    }
  }
}
