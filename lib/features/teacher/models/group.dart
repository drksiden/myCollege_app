class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromMap(Map<String, dynamic> map, String id) {
    return Group(
      id: id,
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
