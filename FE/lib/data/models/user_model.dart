class UserModel {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role; // 'student' or 'instructor'
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      address: json['address'],
      role: json['role'] ?? 'student',
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
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? address,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StudentModel extends UserModel {
  final int studentId;
  final String studentCode;
  final String? major;
  final int? year;

  StudentModel({
    required super.id,
    required super.username,
    required super.email,
    super.phoneNumber,
    super.address,
    required super.createdAt,
    super.updatedAt,
    required this.studentId,
    required this.studentCode,
    this.major,
    this.year,
  }) : super(role: 'student');

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      address: json['address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      studentId: json['student_id'] ?? 0,
      studentCode: json['student_code'] ?? '',
      major: json['major'],
      year: json['year'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'student_id': studentId,
      'student_code': studentCode,
      'major': major,
      'year': year,
    });
    return json;
  }
}

class InstructorModel extends UserModel {
  final int instructorId;
  final String? department;
  final String? title;
  final String? bio;

  InstructorModel({
    required super.id,
    required super.username,
    required super.email,
    super.phoneNumber,
    super.address,
    required super.createdAt,
    super.updatedAt,
    required this.instructorId,
    this.department,
    this.title,
    this.bio,
  }) : super(role: 'instructor');

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      address: json['address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      instructorId: json['instructor_id'] ?? 0,
      department: json['department'],
      title: json['title'],
      bio: json['bio'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'instructor_id': instructorId,
      'department': department,
      'title': title,
      'bio': bio,
    });
    return json;
  }
}

