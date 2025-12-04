import '../models/forum_model.dart';
import '../services/api_service.dart';

class ForumRepository {
  final ApiService _apiService = ApiService();

  // Get topics for a course
  Future<List<TopicModel>> getCourseTopics(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/topics');
      final List<dynamic> topicsJson = response is List
          ? response
          : (response['topics'] ?? response['data'] ?? []);
      return topicsJson.map((json) => TopicModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  // Get topic by ID
  Future<TopicModel> getTopicById(int topicId) async {
    try {
      final response = await _apiService.get('/topics/$topicId');
      return TopicModel.fromJson(response['topic'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to load topic: $e');
    }
  }

  // Create topic
  Future<TopicModel> createTopic(Map<String, dynamic> topicData) async {
    try {
      final response = await _apiService.post('/topics', topicData);
      return TopicModel.fromJson(response['topic'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to create topic: $e');
    }
  }

  // Update topic
  Future<TopicModel> updateTopic(int topicId, Map<String, dynamic> topicData) async {
    try {
      final response = await _apiService.put('/topics/$topicId', topicData);
      return TopicModel.fromJson(response['topic'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update topic: $e');
    }
  }

  // Delete topic
  Future<void> deleteTopic(int topicId) async {
    try {
      await _apiService.delete('/topics/$topicId');
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  // Get topic chats
  Future<List<TopicChatModel>> getTopicChats(int topicId) async {
    try {
      final response = await _apiService.get('/topics/$topicId/chats');
      final List<dynamic> chatsJson = response is List
          ? response
          : (response['chats'] ?? response['data'] ?? []);
      return chatsJson.map((json) => TopicChatModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  // Add chat to topic
  Future<TopicChatModel> addTopicChat(Map<String, dynamic> chatData) async {
    try {
      final response = await _apiService.post('/topic-chats', chatData);
      return TopicChatModel.fromJson(response['chat'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to add chat: $e');
    }
  }

  // Delete topic chat
  Future<void> deleteTopicChat(int chatId) async {
    try {
      await _apiService.delete('/topic-chats/$chatId');
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // Get announcements for a course
  Future<List<AnnouncementModel>> getCourseAnnouncements(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/announcements');
      final List<dynamic> announcementsJson = response is List
          ? response
          : (response['announcements'] ?? response['data'] ?? []);
      return announcementsJson.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load announcements: $e');
    }
  }

  // Get announcement by ID
  Future<AnnouncementModel> getAnnouncementById(int announcementId) async {
    try {
      final response = await _apiService.get('/announcements/$announcementId');
      return AnnouncementModel.fromJson(response['announcement'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to load announcement: $e');
    }
  }

  // Create announcement (instructor only)
  Future<AnnouncementModel> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final response = await _apiService.post('/announcements', announcementData);
      return AnnouncementModel.fromJson(response['announcement'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // Update announcement (instructor only)
  Future<AnnouncementModel> updateAnnouncement(
    int announcementId,
    Map<String, dynamic> announcementData,
  ) async {
    try {
      final response = await _apiService.put('/announcements/$announcementId', announcementData);
      return AnnouncementModel.fromJson(response['announcement'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  // Delete announcement (instructor only)
  Future<void> deleteAnnouncement(int announcementId) async {
    try {
      await _apiService.delete('/announcements/$announcementId');
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  // Get comments for announcement
  Future<List<CommentModel>> getAnnouncementComments(int announcementId) async {
    try {
      final response = await _apiService.get('/announcements/$announcementId/comments');
      final List<dynamic> commentsJson = response is List
          ? response
          : (response['comments'] ?? response['data'] ?? []);
      return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  // Add comment to announcement
  Future<CommentModel> addComment(Map<String, dynamic> commentData) async {
    try {
      final response = await _apiService.post('/comments', commentData);
      return CommentModel.fromJson(response['comment'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Delete comment
  Future<void> deleteComment(int commentId) async {
    try {
      await _apiService.delete('/comments/$commentId');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}

