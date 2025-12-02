class GroupModel {
  final int id;
  final int courseId;
  final String? courseName;
  final String groupName;
  final int students;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.groupName,
    required this.students,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['group_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      groupName: json['group_name'] ?? '',
      students: json['students'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'group_name': groupName,
      'students': students,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
