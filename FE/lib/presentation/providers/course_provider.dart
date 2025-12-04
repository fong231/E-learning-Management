import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/models/content_model.dart';
import '../../data/repositories/course_repository.dart';

class CourseProvider with ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository();

  List<SemesterModel> _semesters = [];
  SemesterModel? _currentSemester;
  List<CourseModel> _courses = [];
  CourseModel? _currentCourse;
  List<GroupModel> _groups = [];
  List<LearningContentModel> _content = [];
  bool _isLoading = false;
  String? _error;

  List<SemesterModel> get semesters => _semesters;
  SemesterModel? get currentSemester =>
      _semesters.isNotEmpty ? _semesters.last : null;
  List<CourseModel> get courses => _courses;
  CourseModel? get currentCourse => _currentCourse;
  List<GroupModel> get groups => _groups;
  List<LearningContentModel> get content => _content;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourse(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCourse = await _courseRepository.getCourseById(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseContent(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _content = await _courseRepository.getCourseContent(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSemesters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _semesters = await _courseRepository.getSemesters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentCoursesWithSemester(int semesterId, [int? studentId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _courseRepository.getStudentCoursesWithSemester(semesterId, studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInstructorCoursesWithSemester(int semesterId, [int? instructorId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _courseRepository.getInstructorCoursesWithSemester(semesterId, instructorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _courseRepository.createCourse(courseData);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _courseRepository.updateCourse(courseId, courseData);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _courseRepository.deleteCourse(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: GET /courses/{courseId}/groups
  Future<void> loadCourseGroups(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _courseRepository.getCourseGroups(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /groups
  Future<void> createGroup(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _courseRepository.createGroup(courseId);
      _error = null;
      await loadCourseGroups(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // WORKING: POST /groups/{groupId}/students
  Future<void> enrollStudentToGroup(int studentId, int groupId) async {
    try {
      await _courseRepository.enrollStudent(studentId, groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // WORKING: DELETE /groups/{groupId}/students/{studentId}
  Future<void> unenrollStudentFromGroup(int studentId, int groupId) async {
    try {
      await _courseRepository.unenrollStudent(studentId, groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

