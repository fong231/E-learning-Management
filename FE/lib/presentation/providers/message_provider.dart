import 'package:flutter/foundation.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/message_repository.dart';

class MessageProvider with ChangeNotifier {
  final MessageRepository _messageRepository = MessageRepository();

  List<MessageModel> _messages = [];
  List<MessageModel> _conversation = [];
  List<NotificationModel> _notifications = [];
  int _unreadMessages = 0;
  int _unreadNotifications = 0;
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  List<MessageModel> get conversation => _conversation;
  List<NotificationModel> get notifications => _notifications;
  int get unreadMessages => _unreadMessages;
  int get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // WORKING: GET /users/{userId}/messages
  Future<void> loadUserMessages(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _messageRepository.getUserMessages(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /messages/conversation/{userId1}/{userId2}
  Future<void> loadConversation(int userId1, int userId2) async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversation = await _messageRepository.getConversation(userId1, userId2);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /messages
  Future<MessageModel?> sendMessage(Map<String, dynamic> messageData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _messageRepository.sendMessage(messageData);
      _messages = [..._messages, message];
      _error = null;
      return message;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /messages/{messageId}/read
  Future<void> markMessageAsRead(int messageId) async {
    try {
      await _messageRepository.markAsRead(messageId);
      _messages = _messages
          .map((m) => m.id == messageId
              ? MessageModel(
                  id: m.id,
                  senderId: m.senderId,
                  senderName: m.senderName,
                  senderRole: m.senderRole,
                  receiverId: m.receiverId,
                  receiverName: m.receiverName,
                  receiverRole: m.receiverRole,
                  content: m.content,
                  isRead: true,
                  sentAt: m.sentAt,
                )
              : m)
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // WORKING: DELETE /messages/{messageId}
  Future<void> deleteMessage(int messageId) async {
    try {
      await _messageRepository.deleteMessage(messageId);
      _messages = _messages.where((m) => m.id != messageId).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // WORKING: GET /students/{studentId}/notifications
  Future<void> loadNotifications(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _messageRepository.getNotifications(studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /notifications/{notificationId}/read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _messageRepository.markNotificationAsRead(notificationId);
      _notifications = _notifications
          .map((n) => n.id == notificationId
              ? NotificationModel(
                  id: n.id,
                  studentId: n.studentId,
                  type: n.type,
                  title: n.title,
                  content: n.content,
                  isRead: true,
                  createdAt: n.createdAt,
                )
              : n)
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // WORKING: DELETE /notifications/{notificationId}
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _messageRepository.deleteNotification(notificationId);
      _notifications = _notifications.where((n) => n.id != notificationId).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // WORKING: GET /users/{userId}/messages/unread-count
  // and GET /students/{studentId}/notifications/unread-count
  Future<void> refreshUnreadCounts({required int userId, required int studentId}) async {
    try {
      _unreadMessages = await _messageRepository.getUnreadCount(userId);
      _unreadNotifications = await _messageRepository.getUnreadNotificationCount(studentId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
