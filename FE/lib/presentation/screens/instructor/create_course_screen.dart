import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _numberOfSessionsController = TextEditingController();
  final _semesterController = TextEditingController();

  int? _selectedSemesterId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.name ?? '';
      _descriptionController.text = widget.description ?? '';
      _numberOfSessionsController.text = widget.numberOfSessions?.toString() ?? '';
      _selectedSemesterId = widget.semesterId;
    } else {
      _loadSemesters();
    }
  }

  Future<void> _loadSemesters() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadSemesters();

    _semesterController.text =
        courseProvider.currentSemester?.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _numberOfSessionsController.dispose();
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
      'number_of_sessions': int.parse(_numberOfSessionsController.text),
      'start_date': _startDate,
      'end_date': _endDate,
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
              validator: (value) {
                if (_selectedSemesterId == null) {
                  return 'Please select semester';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _numberOfSessionsController,
              decoration: const InputDecoration(
                labelText: 'Number of Sessions *',
                hintText: 'Enter number of sessions',
                prefixIcon: Icon(Icons.class_),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of sessions';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
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
