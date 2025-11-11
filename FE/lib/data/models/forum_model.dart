class TopicModel {
  final int id;
  final int courseId;
  final String? courseName;
  final int creatorId;
  final String? creatorName;
  final String creatorRole;
  final String title;
  final String content;
  final int viewCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TopicModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.creatorId,
    this.creatorName,
    required this.creatorRole,
    required this.title,
    required this.content,
    this.viewCount = 0,
    this.replyCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['topic_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      creatorId: json['creator_id'] ?? 0,
      creatorName: json['creator_name'],
      creatorRole: json['creator_role'] ?? 'student',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      viewCount: json['view_count'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
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
      'topic_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_role': creatorRole,
      'title': title,
      'content': content,
      'view_count': viewCount,
      'reply_count': replyCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class TopicChatModel {
  final int id;
  final int topicId;
  final int userId;
  final String? userName;
  final String userRole;
  final String message;
  final DateTime createdAt;

  TopicChatModel({
    required this.id,
    required this.topicId,
    required this.userId,
    this.userName,
    required this.userRole,
    required this.message,
    required this.createdAt,
  });

  factory TopicChatModel.fromJson(Map<String, dynamic> json) {
    return TopicChatModel(
      id: json['chat_id'] ?? json['id'] ?? 0,
      topicId: json['topic_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'],
      userRole: json['user_role'] ?? 'student',
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': id,
      'topic_id': topicId,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AnnouncementModel {
  final int id;
  final int courseId;
  final String? courseName;
  final int instructorId;
  final String? instructorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AnnouncementModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.instructorId,
    this.instructorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['announcement_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      instructorId: json['instructor_id'] ?? 0,
      instructorName: json['instructor_name'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
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
      'announcement_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CommentModel {
  final int id;
  final int? announcementId;
  final int? topicId;
  final int userId;
  final String? userName;
  final String userRole;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    this.announcementId,
    this.topicId,
    required this.userId,
    this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['comment_id'] ?? json['id'] ?? 0,
      announcementId: json['announcement_id'],
      topicId: json['topic_id'],
      userId: json['user_id'] ?? 0,
      userName: json['user_name'],
      userRole: json['user_role'] ?? 'student',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': id,
      'announcement_id': announcementId,
      'topic_id': topicId,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

