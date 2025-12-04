import 'package:flutter/foundation.dart';

import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizProvider with ChangeNotifier {
  final QuizRepository _quizRepository = QuizRepository();

  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  List<QuestionModel> _questions = [];
  List<QuizAttemptModel> _attempts = [];
  bool _isLoading = false;
  String? _error;

  List<QuizModel> get quizzes => _quizzes;
  QuizModel? get currentQuiz => _currentQuiz;
  List<QuestionModel> get questions => _questions;
  List<QuizAttemptModel> get attempts => _attempts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // WORKING: GET /courses/{courseId}/quizzes
  Future<void> loadCourseQuizzes(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _quizzes = await _quizRepository.getCourseQuizzes(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /quizzes/{quizId}
  Future<void> loadQuiz(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentQuiz = await _quizRepository.getQuizById(quizId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /quizzes
  Future<QuizModel> createQuiz(Map<String, dynamic> quizData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _quizRepository.createQuiz(quizData);
      _quizzes = [..._quizzes, created];
      _error = null;
      return created;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /quizzes/{quizId}
  Future<void> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _quizRepository.updateQuiz(quizId, quizData);
      _quizzes = _quizzes.map((q) => q.id == updated.id ? updated : q).toList();
      if (_currentQuiz?.id == updated.id) {
        _currentQuiz = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /quizzes/{quizId}
  Future<void> deleteQuiz(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _quizRepository.deleteQuiz(quizId);
      _quizzes = _quizzes.where((q) => q.id != quizId).toList();
      if (_currentQuiz?.id == quizId) {
        _currentQuiz = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /quizzes/{quizId}/questions
  Future<void> loadQuizQuestions(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _questions = await _quizRepository.getQuizQuestions(quizId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /questions
  Future<void> addQuestion(Map<String, dynamic> questionData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _quizRepository.addQuestion(questionData);
      _questions = [..._questions, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /questions/{questionId}
  Future<void> updateQuestion(int questionId, Map<String, dynamic> questionData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _quizRepository.updateQuestion(questionId, questionData);
      _questions = _questions.map((q) => q.id == updated.id ? updated : q).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /questions/{questionId}
  Future<void> deleteQuestion(int questionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _quizRepository.deleteQuestion(questionId);
      _questions = _questions.where((q) => q.id != questionId).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /quiz-attempts
  Future<void> startQuizAttempt(int quizId, int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final attempt = await _quizRepository.startQuizAttempt(quizId, studentId);
      _attempts = [..._attempts, attempt];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /quiz-attempts/{attemptId}/submit
  Future<void> submitQuizAttempt(int attemptId, Map<int, String> answers) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _quizRepository.submitQuizAttempt(attemptId, answers);
      _attempts = _attempts.map((a) => a.id == updated.id ? updated : a).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /quizzes/{quizId}/attempts?student_id={studentId}
  Future<void> loadStudentAttempts(int quizId, int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _attempts = await _quizRepository.getStudentAttempts(quizId, studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /quizzes/{quizId}/attempts
  Future<void> loadQuizAttempts(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _attempts = await _quizRepository.getQuizAttempts(quizId);
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
