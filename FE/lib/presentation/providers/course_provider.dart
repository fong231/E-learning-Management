import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

class CourseProvider with ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository();

  List<SemesterModel> _semesters = [];
  SemesterModel? _currentSemester;
  List<CourseModel> _courses = [];
  CourseModel? _currentCourse;
  bool _isLoading = false;
  String? _error;

  List<SemesterModel> get semesters => _semesters;
  SemesterModel? get currentSemester => _semesters.last;
  List<CourseModel> get courses => _courses;
  CourseModel? get currentCourse => _currentCourse;
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

