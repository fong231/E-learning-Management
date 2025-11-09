class QuizModel {
  final int id;
  final int courseId;
  final String? courseName;
  final String title;
  final String? description;
  final int duration; // in minutes
  final int numberOfAttempts;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QuizModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.title,
    this.description,
    required this.duration,
    this.numberOfAttempts = 1,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['quiz_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      title: json['title'] ?? '',
      description: json['description'],
      duration: json['duration'] ?? 30,
      numberOfAttempts: json['number_of_attempts'] ?? 1,
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : null,
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
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
      'quiz_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'title': title,
      'description': description,
      'duration': duration,
      'number_of_attempts': numberOfAttempts,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAvailable {
    final now = DateTime.now();
    if (startTime != null && now.isBefore(startTime!)) return false;
    if (endTime != null && now.isAfter(endTime!)) return false;
    return true;
  }
}

class QuestionModel {
  final int id;
  final int quizId;
  final String questionText;
  final String questionType; // 'multiple_choice', 'true_false', 'short_answer'
  final String level; // 'easy_question', 'medium_question', 'hard_question'
  final int points;
  final List<String>? options;
  final String? correctAnswer;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.level,
    this.points = 1,
    this.options,
    this.correctAnswer,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<String>? optionsList;
    if (json['options'] != null) {
      if (json['options'] is List) {
        optionsList = List<String>.from(json['options']);
      } else if (json['options'] is String) {
        optionsList = (json['options'] as String).split('|');
      }
    }

    return QuestionModel(
      id: json['question_id'] ?? json['id'] ?? 0,
      quizId: json['quiz_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'multiple_choice',
      level: json['level'] ?? 'medium_question',
      points: json['points'] ?? 1,
      options: optionsList,
      correctAnswer: json['correct_answer'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType,
      'level': level,
      'points': points,
      'options': options,
      'correct_answer': correctAnswer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get levelDisplay {
    switch (level) {
      case 'easy_question':
        return 'Easy';
      case 'medium_question':
        return 'Medium';
      case 'hard_question':
        return 'Hard';
      default:
        return 'Medium';
    }
  }
}

class QuizAttemptModel {
  final int id;
  final int quizId;
  final int studentId;
  final String? studentName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;
  final int attemptNumber;

  QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    this.studentName,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.attemptNumber,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['attempt_id'] ?? json['id'] ?? 0,
      quizId: json['quiz_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      score: json['score']?.toDouble(),
      attemptNumber: json['attempt_number'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': id,
      'quiz_id': quizId,
      'student_id': studentId,
      'student_name': studentName,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'score': score,
      'attempt_number': attemptNumber,
    };
  }

  bool get isCompleted => completedAt != null;
  
  Duration? get duration => completedAt?.difference(startedAt);
}

