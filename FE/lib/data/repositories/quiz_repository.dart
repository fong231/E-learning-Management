import '../models/quiz_model.dart';
import '../services/api_service.dart';

class QuizRepository {
  final ApiService _apiService = ApiService();

  // Get all quizzes for a course
  Future<List<QuizModel>> getCourseQuizzes(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/quizzes');
      final List<dynamic> quizzesJson = response is List
          ? response
          : (response['quizzes'] ?? response['data'] ?? []);
      return quizzesJson.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  // Get quiz by ID
  Future<QuizModel> getQuizById(int quizId) async {
    try {
      final response = await _apiService.get('/quizzes/$quizId');
      return QuizModel.fromJson(response['quiz'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  // Create quiz (instructor only)
  Future<QuizModel> createQuiz(Map<String, dynamic> quizData) async {
    try {
      final response = await _apiService.post('/quizzes', quizData);
      return QuizModel.fromJson(response['quiz'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  // Update quiz (instructor only)
  Future<QuizModel> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    try {
      final response = await _apiService.put('/quizzes/$quizId', quizData);
      return QuizModel.fromJson(response['quiz'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  // Delete quiz (instructor only)
  Future<void> deleteQuiz(int quizId) async {
    try {
      await _apiService.delete('/quizzes/$quizId');
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // Get questions for a quiz
  Future<List<QuestionModel>> getQuizQuestions(int quizId) async {
    try {
      final response = await _apiService.get('/quizzes/$quizId/questions');
      final List<dynamic> questionsJson = response is List
          ? response
          : (response['questions'] ?? response['data'] ?? []);
      return questionsJson.map((json) => QuestionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  // Add question to quiz (instructor only)
  Future<QuestionModel> addQuestion(Map<String, dynamic> questionData) async {
    try {
      final response = await _apiService.post('/questions', questionData);
      return QuestionModel.fromJson(response['question'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  // Update question (instructor only)
  Future<QuestionModel> updateQuestion(
    int questionId,
    Map<String, dynamic> questionData,
  ) async {
    try {
      final response = await _apiService.put('/questions/$questionId', questionData);
      return QuestionModel.fromJson(response['question'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  // Delete question (instructor only)
  Future<void> deleteQuestion(int questionId) async {
    try {
      await _apiService.delete('/questions/$questionId');
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // Start quiz attempt (student)
  Future<QuizAttemptModel> startQuizAttempt(int quizId, int studentId) async {
    try {
      final response = await _apiService.post('/quiz-attempts', {
        'quiz_id': quizId,
        'student_id': studentId,
      });
      return QuizAttemptModel.fromJson(response['attempt'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to start quiz: $e');
    }
  }

  // Submit quiz attempt (student)
  Future<QuizAttemptModel> submitQuizAttempt(
    int attemptId,
    Map<int, String> answers,
  ) async {
    try {
      final response = await _apiService.post('/quiz-attempts/$attemptId/submit', {
        'answers': answers,
      });
      return QuizAttemptModel.fromJson(response['attempt'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // Get student's quiz attempts
  Future<List<QuizAttemptModel>> getStudentAttempts(int quizId, int studentId) async {
    try {
      final response = await _apiService.get(
        '/quizzes/$quizId/attempts?student_id=$studentId',
      );
      final List<dynamic> attemptsJson = response is List
          ? response
          : (response['attempts'] ?? response['data'] ?? []);
      return attemptsJson.map((json) => QuizAttemptModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load attempts: $e');
    }
  }

  // Get all attempts for a quiz (instructor only)
  Future<List<QuizAttemptModel>> getQuizAttempts(int quizId) async {
    try {
      final response = await _apiService.get('/quizzes/$quizId/attempts');
      final List<dynamic> attemptsJson = response is List
          ? response
          : (response['attempts'] ?? response['data'] ?? []);
      return attemptsJson.map((json) => QuizAttemptModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load attempts: $e');
    }
  }
}

