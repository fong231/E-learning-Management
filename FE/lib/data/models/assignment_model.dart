class AssignmentModel { 
  final int id;
  final int? courseId;
  final String? courseName;
  final int groupId;
  final String title;
  final String? description;
  final DateTime deadline;
  final DateTime late_deadline;
  final String? size_limit;
  final String? file_format;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> filesUrl;

  AssignmentModel({
    required this.id,
    this.courseId,
    this.courseName,
    required this.groupId,
    required this.title,
    this.description,
    required this.deadline,
    required this.late_deadline,
    this.size_limit,
    this.file_format,
    required this.createdAt,
    this.updatedAt,
    this.filesUrl = const [],
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['assignment_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      groupId: json['group_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      late_deadline: DateTime.parse(json['late_deadline']),
      size_limit: json['size_limit'],
      file_format: json['file_format'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      filesUrl: json['files_url'] != null ? List<String>.from(json['files_url']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'group_id': groupId,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'late_deadline': late_deadline.toIso8601String(),
      'size_limit': size_limit,
      'file_format': file_format,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'files_url': filesUrl,
    };
  }

  bool get isOverdue => DateTime.now().isAfter(deadline);
  
  Duration get timeRemaining => deadline.difference(DateTime.now());
}

class AssignmentSubmissionModel {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? studentName;
  final String? submissionText;
  final String? fileUrl;
  final DateTime submittedAt;
  final double? score;
  final String? feedback;
  final DateTime? gradedAt;

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.submissionText,
    this.fileUrl,
    required this.submittedAt,
    this.score,
    this.feedback,
    this.gradedAt,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionModel(
      id: json['submission_id'] ?? json['id'] ?? 0,
      assignmentId: json['assignment_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'],
      submissionText: json['submission_text'],
      fileUrl: json['file_url'],
      submittedAt: DateTime.parse(json['submitted_at']),
      score: json['score']?.toDouble(),
      feedback: json['feedback'],
      gradedAt: json['graded_at'] != null 
          ? DateTime.parse(json['graded_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'student_name': studentName,
      'submission_text': submissionText,
      'file_url': fileUrl,
      'submitted_at': submittedAt.toIso8601String(),
      'score': score,
      'feedback': feedback,
      'graded_at': gradedAt?.toIso8601String(),
    };
  }

  bool get isGraded => score != null;
}

