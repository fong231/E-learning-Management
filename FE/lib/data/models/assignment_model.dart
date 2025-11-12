class AssignmentModel {
  final int id;
  final int courseId;
  final String? courseName;
  final String title;
  final String? description;
  final DateTime deadline;
  final int maxScore;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AssignmentModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.title,
    this.description,
    required this.deadline,
    this.maxScore = 100,
    required this.createdAt,
    this.updatedAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['assignment_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      title: json['title'] ?? '',
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      maxScore: json['max_score'] ?? 100,
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
      'assignment_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'max_score': maxScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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

