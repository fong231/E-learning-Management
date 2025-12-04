import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/summary_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class InstructorRepository {
  final ApiService _apiService = ApiService();

  // Get instructor Summary
  Future<SummaryModel> getInstructorSummary([int? instructorId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      instructorId = prefs.getInt(AppConstants.userIdKey) ?? instructorId;

      final response = await _apiService.get('/instructors/$instructorId/summary');
      return SummaryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load summary: $e');
    }
  }

  Future<List<UserModel>> getInstructorStudents([int? instructorId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      instructorId = prefs.getInt(AppConstants.userIdKey) ?? instructorId;

      final response = await _apiService.get('/instructors/$instructorId/students');
      final List<dynamic> studentsJson = response is List
          ? response
          : (response['students'] ?? response['data'] ?? []);
      return studentsJson.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  Future<List<UserModel>> getStudentsInCourse(int courseId) async {
    try {
      final response = await _apiService.get('/instructors/students/courses/$courseId');
      final List<dynamic> studentsJson = response is List
          ? response
          : (response['students'] ?? response['data'] ?? []);
      return studentsJson.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

}