import 'package:flutter/foundation.dart';
import '../../data/models/summary_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/instructor_repository.dart';

class InstructorStudentProvider with ChangeNotifier {
  final InstructorRepository _instructorRepository = InstructorRepository();

  List<UserModel> _students = [];
  SummaryModel? _summary;
  bool _isLoading = false;
  String? _error;

  List<UserModel> get students => _students;
  SummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInstructorStudents([int? instructorId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await _instructorRepository.getInstructorStudents(instructorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsInCourse(int courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await _instructorRepository.getStudentsInCourse(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}