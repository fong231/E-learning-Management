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
      totalCourses: json['total_courses'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      totalGroups: json['total_groups'] ?? 0,
      totalAssignments: json['total_assignments'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_courses': totalCourses,
      'total_students': totalStudents,
      'total_groups': totalGroups,
      'total_assignments': totalAssignments,
      'total_quizzes': totalQuizzes,
    };
  }
}
