import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({
    super.key,
    this.isEdit = false,
    this.courseId,
    this.name,
    this.description,
    this.semesterId,
    this.numberOfSessions,
  });

  final bool isEdit;
  final int? courseId;
  final String? name;
  final String? description;
  final int? semesterId;
  final int? numberOfSessions;

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _semesterController = TextEditingController();

  int? _selectedSemesterId;
  int? _selectedNumberOfSessions;
  List<SemesterModel> _semesters = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _descriptionController.text = widget.description ?? '';
    _selectedSemesterId = widget.semesterId;
    _selectedNumberOfSessions = widget.numberOfSessions;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSemesters();
    });
  }

  Future<void> _loadSemesters() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadSemesters();
    _semesters = courseProvider.semesters;

    if (_semesters.isEmpty) {
      return;
    }

    SemesterModel? selected;
    if (_selectedSemesterId != null) {
      for (final s in _semesters) {
        if (s.id == _selectedSemesterId) {
          selected = s;
          break;
        }
      }
    }

    selected ??= courseProvider.currentSemester ?? _semesters.last;
    _selectedSemesterId = selected.id;
    _semesterController.text = selected.description;

    _selectedNumberOfSessions ??= 10;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.createCourse({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'semester_id': _selectedSemesterId,
      'number_of_sessions': _selectedNumberOfSessions,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create course successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name *',
                hintText: 'Enter course name',
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter course description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _semesterController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Semester *',
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                if (_semesters.isEmpty) return;

                final selectedId = await showDialog<int>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Select Semester'),
                    children: [
                      for (final semester in _semesters)
                        SimpleDialogOption(
                          onPressed: () =>
                              Navigator.of(context).pop(semester.id),
                          child: Text(semester.description),
                        ),
                    ],
                  ),
                );

                if (selectedId != null) {
                  final courseProvider =
                      Provider.of<CourseProvider>(context, listen: false);

                  await courseProvider.setSelectedSemester(selectedId);

                  setState(() {
                    _selectedSemesterId = selectedId;
                    final semester = _semesters.firstWhere(
                      (s) => s.id == selectedId,
                      orElse: () => _semesters.last,
                    );
                    _semesterController.text = semester.description;
                  });
                }
              },
              validator: (value) {
                if (_selectedSemesterId == null) {
                  return 'Please select semester';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedNumberOfSessions,
              decoration: const InputDecoration(
                labelText: 'Number of Sessions *',
                prefixIcon: Icon(Icons.class_),
              ),
              items: const [
                DropdownMenuItem(
                  value: 10,
                  child: Text('10 sessions'),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text('15 sessions'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedNumberOfSessions = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select number of sessions';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Consumer<CourseProvider>(
              builder: (context, courseProvider, child) {
                return ElevatedButton(
                  onPressed: courseProvider.isLoading ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: courseProvider.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(widget.isEdit ? 'Update Course' : 'Create Course'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
