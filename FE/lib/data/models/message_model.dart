class MessageModel {
  final int id;
  final int senderId;
  final String? senderName;
  final String senderRole;
  final int receiverId;
  final String? receiverName;
  final String receiverRole;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.receiverId,
    this.receiverName,
    required this.receiverRole,
    required this.content,
    this.isRead = false,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['message_id'] ?? json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'],
      senderRole: json['sender_role'] ?? 'student',
      receiverId: json['receiver_id'] ?? 0,
      receiverName: json['receiver_name'],
      receiverRole: json['receiver_role'] ?? 'instructor',
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_role': receiverRole,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

class NotificationModel {
  final int id;
  final int studentId;
  final String type; // 'announcement', 'deadline', 'feedback', 'submission', 'message', 'other'
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.studentId,
    required this.type,
    required this.title,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] ?? json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      type: json['type'] ?? 'other',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'student_id': studentId,
      'type': type,
      'title': title,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeDisplay {
    switch (type) {
      case 'announcement':
        return 'Notifications';
      case 'deadline':
        return 'Hạn chót';
      case 'feedback':
        return 'Phản hồi';
      case 'submission':
        return 'Submit';
      case 'message':
        return 'Messages';
      default:
        return 'Khác';
    }
  }
}

