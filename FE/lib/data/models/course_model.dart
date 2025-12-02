class CourseModel {
  final int id;
  final String name;
  final String? description;
  final int instructorId;
  final String? instructorName;
  final int semesterId;
  final String? semesterName;
  final int numberOfSessions;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.name,
    this.description,
    required this.instructorId,
    this.instructorName,
    required this.semesterId,
    this.semesterName,
    required this.numberOfSessions,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['course_id'] ?? json['id'] ?? 0,
      name: json['course_name'] ?? json['name'] ?? '',
      description: json['description'],
      instructorId: json['instructor_id'] ?? 0,
      instructorName: json['instructor_name'],
      semesterId: json['semester_id'] ?? 0,
      semesterName: json['semester_name'],
      numberOfSessions: json['number_of_sessions'] ?? 10,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': id,
      'course_name': name,
      'description': description,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'semester_id': semesterId,
      'semester_name': semesterName,
      'number_of_sessions': numberOfSessions,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class SemesterModel {
  final int id;
  final String description;

  SemesterModel({
    required this.id,
    required this.description,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['semester_id'] ?? json['id'] ?? 0,
      description: json['semester_description'] ?? json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semester_id': id,
      'description': description,
    };
  }
}

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

