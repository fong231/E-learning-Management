import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/course_model.dart';
import '../models/content_model.dart';
import '../services/api_service.dart';

class CourseRepository {
  final ApiService _apiService = ApiService();

  // Get all courses
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _apiService.get('/courses');
      final List<dynamic> coursesJson = response is List
          ? response
          : (response['courses'] ?? response['data'] ?? []);
      return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  // Get courses for student with semester
  Future<List<CourseModel>> getStudentCoursesWithSemester(int semesterId, [int? studentId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      studentId = prefs.getInt(AppConstants.userIdKey) ?? studentId;

      final response = await _apiService.get('/students/$studentId/courses?semester_id=$semesterId');
      final List<dynamic> coursesJson = response is List
          ? response
          : (response['courses'] ?? response['data'] ?? []);
      return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load student courses: $e');
    }
  }

  // Get all courses for student (all semesters)
  Future<List<CourseModel>> getStudentCoursesAll([int? studentId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      studentId = prefs.getInt(AppConstants.userIdKey) ?? studentId;

      final response = await _apiService.get('/students/$studentId/courses');
      final List<dynamic> coursesJson = response is List
          ? response
          : (response['courses'] ?? response['data'] ?? []);
      return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load student courses: $e');
    }
  }

  // Get courses for instructor with semester
  Future<List<CourseModel>> getInstructorCoursesWithSemester(int semesterId, [int? instructorId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      instructorId = prefs.getInt(AppConstants.userIdKey) ?? instructorId;

      final response = await _apiService.get('/instructors/$instructorId/courses?semester_id=$semesterId');
      final List<dynamic> coursesJson = response is List
          ? response
          : (response['courses'] ?? response['data'] ?? []);
      return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load instructor courses: $e');
    }
  }

  // Get course by ID
  Future<CourseModel> getCourseById(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId');
      return CourseModel.fromJson(response['course'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to load course: $e');
    }
  }

  // Create course (instructor only)
  Future<CourseModel> createCourse(Map<String, dynamic> courseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final instructorId = prefs.getInt(AppConstants.userIdKey);

      final payload = <String, dynamic>{
        'course_name': courseData['course_name'] ?? courseData['name'],
        'description': courseData['description'],
        'semesterID': courseData['semesterID'] ?? courseData['semester_id'],
        'number_of_sessions':
            (courseData['number_of_sessions'] ?? '').toString(),
        if (instructorId != null) 'instructorID': instructorId,
      };

      final response = await _apiService.post('/courses', payload);
      final data = response is Map<String, dynamic>
          ? (response['course'] ?? response['data'] ?? response)
          : response;
      return CourseModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  // Update course (instructor only)
  Future<CourseModel> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.put('/courses/$courseId', courseData);
      return CourseModel.fromJson(response['course'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  // Delete course (instructor only)
  Future<void> deleteCourse(int courseId) async {
    try {
      await _apiService.delete('/courses/$courseId');
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // Get course content
  Future<List<LearningContentModel>> getCourseContent(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/content');
      final List<dynamic> contentJson = response is List
          ? response
          : (response['content'] ?? response['data'] ?? []);
      return contentJson.map((json) => LearningContentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load course content: $e');
    }
  }

  // Add content to course
  Future<LearningContentModel> addCourseContent(
    int courseId,
    Map<String, dynamic> contentData,
  ) async {
    try {
      final response = await _apiService.post('/courses/$courseId/content', contentData);
      return LearningContentModel.fromJson(response['content'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to add course content: $e');
    }
  }

  // Update course content
  Future<LearningContentModel> updateCourseContent(
    int contentId,
    Map<String, dynamic> contentData,
  ) async {
    try {
      final response = await _apiService.put('/content/$contentId', contentData);
      return LearningContentModel.fromJson(response['content'] ?? response['data']);
    } catch (e) {
      throw Exception('Failed to update course content: $e');
    }
  }

  // Delete course content
  Future<void> deleteCourseContent(int contentId) async {
    try {
      await _apiService.delete('/content/$contentId');
    } catch (e) {
      throw Exception('Failed to delete course content: $e');
    }
  }

  // Upload a material file for a course
  Future<void> uploadCourseMaterialFile(int courseId, String filePath) async {
    try {
      await _apiService.uploadFile(
        '/courses/$courseId/materials/files',
        filePath,
        'file',
      );
    } catch (e) {
      throw Exception('Failed to upload course material: $e');
    }
  }

  // Create group for a course (instructor only)
  Future<void> createGroup(int courseId) async {
    try {
      await _apiService.post('/groups/', {
        'courseID': courseId,
      });
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Delete group for a course (instructor only)
  Future<void> deleteGroup(int groupId) async {
    try {
      await _apiService.delete('/groups/$groupId');
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Get groups for course
  Future<List<GroupModel>> getCourseGroups(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/groups');
      final List<dynamic> groupsJson = response is List
          ? response
          : (response['groups'] ?? response['data'] ?? []);
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load course groups: $e');
    }
  }

  // Enroll student in a specific group of a course
  Future<void> enrollStudent(int studentId, int groupId) async {
    try {
      await _apiService.post('/groups/$groupId/students', {
        'student_id': studentId,
      });
    } catch (e) {
      throw Exception('Failed to enroll student: $e');
    }
  }

  // Unenroll student from a specific group
  Future<void> unenrollStudent(int studentId, int groupId) async {
    try {
      await _apiService.delete('/groups/$groupId/students/$studentId');
    } catch (e) {
      throw Exception('Failed to unenroll student: $e');
    }
  }

  // Get semesters
  Future<List<SemesterModel>> getSemesters() async {
    try {
      final response = await _apiService.get('/semesters');
      final List<dynamic> semestersJson = response is List
          ? response
          : (response['semesters'] ?? response['data'] ?? []);
      return semestersJson
          .map((json) => SemesterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load semesters: $e');
    }
  }
}

