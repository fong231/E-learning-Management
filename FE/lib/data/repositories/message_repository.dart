import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageRepository {
  final ApiService _apiService = ApiService();

  // Get messages for a user
  Future<List<MessageModel>> getUserMessages(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/messages');
      final List<dynamic> messagesJson = response is List
          ? response
          : (response['messages'] ?? response['data'] ?? []);
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Get conversation between two users
  Future<List<MessageModel>> getConversation(int userId1, int userId2) async {
    try {
      final response = await _apiService.get('/messages/conversation/$userId1/$userId2');
      final List<dynamic> messagesJson = response is List
          ? response
          : (response['messages'] ?? response['data'] ?? []);
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load conversation: $e');
    }
  }

  // Send message
  Future<MessageModel> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await _apiService.post('/messages', messageData);
      return MessageModel.fromJson(response['message'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read
  Future<void> markAsRead(int messageId) async {
    try {
      await _apiService.put('/messages/$messageId/read', {});
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _apiService.delete('/messages/$messageId');
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId/messages/unread-count');
      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get notifications for student
  Future<List<NotificationModel>> getNotifications(int studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId/notifications');
      final List<dynamic> notificationsJson = response is List
          ? response
          : (response['notifications'] ?? response['data'] ?? []);
      return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiService.put('/notifications/$notificationId/read', {});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiService.delete('/notifications/$notificationId');
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(int studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId/notifications/unread-count');
      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

