class AppConstants {
  // API Base URL
  static const String baseUrl = 'http://localhost:8080/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String coursesEndpoint = '/courses';
  static const String assignmentsEndpoint = '/assignments';
  static const String quizzesEndpoint = '/quizzes';
  static const String messagesEndpoint = '/messages';
  static const String notificationsEndpoint = '/notifications';
  static const String topicsEndpoint = '/topics';
  static const String announcementsEndpoint = '/announcements';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';
  
  // App Info
  static const String appName = 'LMS - Learning Management System';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int pageSize = 20;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip', 'rar', 'jpg', 'jpeg', 'png'
  ];
  
  // Quiz Settings
  static const int defaultQuizDuration = 30; // minutes
  static const int defaultNumberOfAttempts = 1;
  
  // Notification Types
  static const String notificationAnnouncement = 'announcement';
  static const String notificationDeadline = 'deadline';
  static const String notificationFeedback = 'feedback';
  static const String notificationSubmission = 'submission';
  static const String notificationMessage = 'message';
  static const String notificationOther = 'other';
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleInstructor = 'instructor';
  
  // Question Levels
  static const String levelEasy = 'easy_question';
  static const String levelMedium = 'medium_question';
  static const String levelHard = 'hard_question';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // AI Settings
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String aiModelName = 'gemini-pro';
}

