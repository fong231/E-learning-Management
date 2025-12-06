import 'package:flutter/foundation.dart';

import '../../data/models/forum_model.dart';
import '../../data/repositories/forum_repository.dart';

class ForumProvider with ChangeNotifier {
  final ForumRepository _forumRepository = ForumRepository();

  List<TopicModel> _topics = [];
  TopicModel? _currentTopic;
  List<TopicChatModel> _chats = [];
  List<AnnouncementModel> _announcements = [];
  AnnouncementModel? _currentAnnouncement;
  List<CommentModel> _comments = [];
  List<TopicFileModel> _topicFiles = [];
  bool _isLoading = false;
  String? _error;

  List<TopicModel> get topics => _topics;

  TopicModel? get currentTopic => _currentTopic;

  List<TopicChatModel> get chats => _chats;

  List<AnnouncementModel> get announcements => _announcements;

  AnnouncementModel? get currentAnnouncement => _currentAnnouncement;

  List<CommentModel> get comments => _comments;

  List<TopicFileModel> get topicFiles => _topicFiles;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // WORKING: GET /courses/{courseId}/topics
  Future<void> loadCourseTopics(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _topics = await _forumRepository.getCourseTopics(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload a file attached to a topic
  Future<void> uploadTopicFile(int topicId, String filePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uploaded = await _forumRepository.uploadTopicFile(
        topicId,
        filePath,
      );
      _topicFiles = [..._topicFiles, uploaded];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get files for a topic
  Future<void> loadTopicFiles(int topicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _topicFiles = await _forumRepository.getTopicFiles(topicId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper: load topics for multiple courses (student view)
  Future<void> loadTopicsForCourses(List<int> courseIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<TopicModel> all = [];

      for (final courseId in courseIds) {
        final topicsForCourse = await _forumRepository.getCourseTopics(
          courseId,
        );
        all.addAll(topicsForCourse);
      }

      _topics = all;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /topics/{topicId}
  Future<void> loadTopic(int topicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentTopic = await _forumRepository.getTopicById(topicId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /topics
  Future<void> createTopic(Map<String, dynamic> topicData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _forumRepository.createTopic(topicData);
      _topics = [..._topics, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /topics/{topicId}
  Future<void> updateTopic(int topicId, Map<String, dynamic> topicData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _forumRepository.updateTopic(topicId, topicData);
      _topics = _topics.map((t) => t.id == updated.id ? updated : t).toList();
      if (_currentTopic?.id == updated.id) {
        _currentTopic = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /topics/{topicId}
  Future<void> deleteTopic(int topicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _forumRepository.deleteTopic(topicId);
      _topics = _topics.where((t) => t.id != topicId).toList();
      if (_currentTopic?.id == topicId) {
        _currentTopic = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /topics/{topicId}/chats
  Future<void> loadTopicChats(int topicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _chats = await _forumRepository.getTopicChats(topicId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /topic-chats
  Future<void> addTopicChat(Map<String, dynamic> chatData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _forumRepository.addTopicChat(chatData);
      _chats = [..._chats, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /topic-chats/{chatId}
  Future<void> deleteTopicChat(int chatId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _forumRepository.deleteTopicChat(chatId);
      _chats = _chats.where((c) => c.id != chatId).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /courses/{courseId}/announcements
  Future<void> loadCourseAnnouncements(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _announcements = await _forumRepository.getCourseAnnouncements(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /announcements/{announcementId}
  Future<void> loadAnnouncement(int announcementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentAnnouncement = await _forumRepository.getAnnouncementById(
        announcementId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /announcements
  Future<void> createAnnouncement(Map<String, dynamic> announcementData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _forumRepository.createAnnouncement(
        announcementData,
      );
      _announcements = [..._announcements, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /announcements/{announcementId}
  Future<void> updateAnnouncement(
    int announcementId,
    Map<String, dynamic> announcementData,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _forumRepository.updateAnnouncement(
        announcementId,
        announcementData,
      );
      _announcements = _announcements
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      if (_currentAnnouncement?.id == updated.id) {
        _currentAnnouncement = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /announcements/{announcementId}
  Future<void> deleteAnnouncement(int announcementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _forumRepository.deleteAnnouncement(announcementId);
      _announcements = _announcements
          .where((a) => a.id != announcementId)
          .toList();
      if (_currentAnnouncement?.id == announcementId) {
        _currentAnnouncement = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /announcements/{announcementId}/comments
  Future<void> loadAnnouncementComments(int announcementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await _forumRepository.getAnnouncementComments(
        announcementId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /comments
  Future<void> addComment(Map<String, dynamic> commentData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _forumRepository.addComment(commentData);
      _comments = [..._comments, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /comments/{commentId}
  Future<void> deleteComment(int commentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _forumRepository.deleteComment(commentId);
      _comments = _comments.where((c) => c.id != commentId).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
