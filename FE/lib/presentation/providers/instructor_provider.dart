import 'package:flutter/foundation.dart';

import '../../data/models/summary_model.dart';
import '../../data/repositories/instructor_repository.dart';

class InstructorProvider with ChangeNotifier {
  final InstructorRepository _instructorRepository = InstructorRepository();

  SummaryModel? _summary;
  bool _isLoading = false;
  String? _error;

  SummaryModel? get summary => _summary;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadInstructorSummary({
    int? instructorId,
    int? semesterId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _summary = await _instructorRepository.getInstructorSummary(
        instructorId: instructorId,
        semesterId: semesterId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
