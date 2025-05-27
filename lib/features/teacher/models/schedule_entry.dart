// TODO Implement this library.
class ScheduleEntry {
  final String id;
  final String groupId;
  final String subjectName;
  final String teacherId;
  final DateTime dateTime;

  ScheduleEntry({
    required this.id,
    required this.groupId,
    required this.subjectName,
    required this.teacherId,
    required this.dateTime,
  });

  factory ScheduleEntry.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleEntry(
      id: id,
      groupId: map['groupId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
