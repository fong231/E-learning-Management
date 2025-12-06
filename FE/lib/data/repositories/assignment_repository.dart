import '../models/assignment_model.dart';
import '../services/api_service.dart';

class AssignmentRepository {
  final ApiService _apiService = ApiService();

  // Get all assignments for a course
  Future<List<AssignmentModel>> getCourseAssignments(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/assignments');
      final List<dynamic> assignmentsJson = response is List
          ? response
          : (response['assignments'] ?? response['data'] ?? []);
      return assignmentsJson.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  // Get assignment by ID
  Future<AssignmentModel> getAssignmentById(int assignmentId) async {
    try {
      final response = await _apiService.get('/assignments/$assignmentId');
      return AssignmentModel.fromJson(response['assignment'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
    }
  }

  // Create assignment (instructor only)
  Future<AssignmentModel> createAssignment(Map<String, dynamic> assignmentData) async {
    try {
      final response = await _apiService.post('/assignments', assignmentData);
      return AssignmentModel.fromJson(response['assignment'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  // Update assignment (instructor only)
  Future<AssignmentModel> updateAssignment(
    int assignmentId,
    Map<String, dynamic> assignmentData,
  ) async {
    try {
      final response = await _apiService.put('/assignments/$assignmentId', assignmentData);
      return AssignmentModel.fromJson(response['assignment'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  // Delete assignment (instructor only)
  Future<void> deleteAssignment(int assignmentId) async {
    try {
      await _apiService.delete('/assignments/$assignmentId');
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  // Get student's submissions for an assignment
  Future<List<AssignmentSubmissionModel>> getStudentSubmissions(
    int assignmentId,
    int studentId,
  ) async {
    try {
      final response = await _apiService.get(
        '/assignments/$assignmentId/submissions?student_id=$studentId',
      );
      final List<dynamic> submissionsJson = response is List
          ? response
          : (response['submissions'] ?? response['data'] ?? []);
      return submissionsJson.map((json) => AssignmentSubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load submissions: $e');
    }
  }

  // Get all submissions for an assignment (instructor only)
  Future<List<AssignmentSubmissionModel>> getAssignmentSubmissions(int assignmentId) async {
    try {
      final response = await _apiService.get('/assignments/$assignmentId/submissions');
      final List<dynamic> submissionsJson = response is List
          ? response
          : (response['submissions'] ?? response['data'] ?? []);
      return submissionsJson.map((json) => AssignmentSubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load submissions: $e');
    }
  }

  // Submit assignment (student)
  Future<AssignmentSubmissionModel> submitAssignment(
    Map<String, dynamic> submissionData,
  ) async {
    try {
      final response = await _apiService.post('/submissions', submissionData);
      return AssignmentSubmissionModel.fromJson(response['submission'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to submit assignment: $e');
    }
  }

  // Upload assignment file
  Future<String> uploadAssignmentFile(String filePath) async {
    try {
      final response = await _apiService.uploadFile(
        '/uploads/assignment',
        filePath,
        'file',
      );
      return response['file_url'] ?? response['url'] ?? '';
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Grade submission (instructor only)
  Future<AssignmentSubmissionModel> gradeSubmission(
    int submissionId,
    double score,
    String? feedback,
  ) async {
    try {
      final response = await _apiService.put('/submissions/$submissionId/grade', {
        'score': score,
        'feedback': feedback,
      });
      return AssignmentSubmissionModel.fromJson(response['submission'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to grade submission: $e');
    }
  }
}

