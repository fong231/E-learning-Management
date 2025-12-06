class SummaryModel {
  final int id;
  final int totalCourses;
  final int totalStudents;
  final int totalGroups;
  final int totalAssignments;
  final int totalQuizzes;

  SummaryModel({
    required this.id,
    required this.totalCourses,
    required this.totalStudents,
    required this.totalGroups,
    required this.totalAssignments,
    required this.totalQuizzes,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] ?? 0,
      totalCourses: json['totalCourses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalGroups: json['totalGroups'] ?? 0,
      totalAssignments: json['totalAssignments'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalCourses': totalCourses,
      'totalStudents': totalStudents,
      'totalGroups': totalGroups,
      'totalAssignments': totalAssignments,
      'totalQuizzes': totalQuizzes,
    };
  }
}
