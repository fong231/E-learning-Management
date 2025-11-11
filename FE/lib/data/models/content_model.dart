class LearningContentModel {
  final int id;
  final int courseId;
  final String? courseName;
  final String title;
  final String? description;
  final String contentType; // 'video', 'document', 'slide', 'link'
  final String? contentUrl;
  final int sessionNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LearningContentModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.title,
    this.description,
    required this.contentType,
    this.contentUrl,
    required this.sessionNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory LearningContentModel.fromJson(Map<String, dynamic> json) {
    return LearningContentModel(
      id: json['content_id'] ?? json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'],
      title: json['title'] ?? '',
      description: json['description'],
      contentType: json['content_type'] ?? 'document',
      contentUrl: json['content_url'],
      sessionNumber: json['session_number'] ?? 1,
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
      'content_id': id,
      'course_id': courseId,
      'course_name': courseName,
      'title': title,
      'description': description,
      'content_type': contentType,
      'content_url': contentUrl,
      'session_number': sessionNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get contentTypeDisplay {
    switch (contentType) {
      case 'video':
        return 'Video';
      case 'document':
        return 'Materials';
      case 'slide':
        return 'Slide';
      case 'link':
        return 'Liên kết';
      default:
        return 'Khác';
    }
  }
}

class MaterialModel {
  final int id;
  final int contentId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;

  MaterialModel({
    required this.id,
    required this.contentId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['material_id'] ?? json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'] ?? 0,
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': id,
      'content_id': contentId,
      'file_name': fileName,
      'file_type': fileType,
      'file_url': fileUrl,
      'file_size': fileSize,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  String get fileSizeDisplay {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

