import 'package:flutter/foundation.dart';

import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';

class AssignmentProvider with ChangeNotifier {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  List<AssignmentModel> _assignments = [];
  AssignmentModel? _currentAssignment;
  List<AssignmentSubmissionModel> _submissions = [];
  bool _isLoading = false;
  String? _error;

  List<AssignmentModel> get assignments => _assignments;
  AssignmentModel? get currentAssignment => _currentAssignment;
  List<AssignmentSubmissionModel> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // WORKING: GET /courses/{courseId}/assignments
  Future<void> loadCourseAssignments(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _assignments = await _assignmentRepository.getCourseAssignments(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /assignments/{assignmentId}
  Future<void> loadAssignment(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentAssignment = await _assignmentRepository.getAssignmentById(assignmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /assignments (+ POST /uploads/assignment if file_path provided)
  Future<void> createAssignment(Map<String, dynamic> assignmentData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _assignmentRepository.createAssignment(assignmentData);
      _assignments = [..._assignments, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: PUT /assignments/{assignmentId}
  Future<void> updateAssignment(int assignmentId, Map<String, dynamic> assignmentData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _assignmentRepository.updateAssignment(assignmentId, assignmentData);
      _assignments = _assignments.map((a) => a.id == updated.id ? updated : a).toList();
      if (_currentAssignment?.id == updated.id) {
        _currentAssignment = updated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: DELETE /assignments/{assignmentId}
  Future<void> deleteAssignment(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _assignmentRepository.deleteAssignment(assignmentId);
      _assignments = _assignments.where((a) => a.id != assignmentId).toList();
      if (_currentAssignment?.id == assignmentId) {
        _currentAssignment = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /assignments/{assignmentId}/submissions?student_id={studentId}
  Future<void> loadStudentSubmissions(int assignmentId, int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _submissions = await _assignmentRepository.getStudentSubmissions(assignmentId, studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /assignments/{assignmentId}/submissions
  Future<void> loadAssignmentSubmissions(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _submissions = await _assignmentRepository.getAssignmentSubmissions(assignmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /submissions
  Future<void> submitAssignment(Map<String, dynamic> submissionData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _assignmentRepository.submitAssignment(submissionData);
      _submissions = [..._submissions, created];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /uploads/assignment (helper)
  Future<String?> uploadAssignmentFile(String filePath) async {
    try {
      final url = await _assignmentRepository.uploadAssignmentFile(filePath);
      return url;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // WORKING: PUT /submissions/{submissionId}/grade
  Future<void> gradeSubmission(int submissionId, double score, String? feedback) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _assignmentRepository.gradeSubmission(submissionId, score, feedback);
      _submissions = _submissions.map((s) => s.id == updated.id ? updated : s).toList();
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
