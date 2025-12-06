import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/course_provider.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key, this.courseId});

  final int? courseId;

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCourseId;
  int? _selectedGroupId;
  File? _selectedFile;
  String? _selectedFileName;
  DateTime? _dueDate;
  DateTime? _lateDueDate;
  bool _isLoading = false;
  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCoursesAndInitialGroups();
    });
  }

  Future<void> _loadCoursesAndInitialGroups() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    await courseProvider.loadSemesters();

    if (courseProvider.semesters.isNotEmpty) {
      final SemesterModel semester = courseProvider.semesters.last;
      await courseProvider.loadInstructorCoursesWithSemester(semester.id);
      _courses = courseProvider.courses;

      if (_courses.isNotEmpty) {
        if (widget.courseId != null) {
          _selectedCourseId = widget.courseId;
        } else {
          _selectedCourseId = _selectedCourseId ?? _courses.first.id;
        }
        await _loadGroupsForCourse(_selectedCourseId!);
      }
    } else {
      _courses = [];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadGroupsForCourse(int courseId) async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourseGroups(courseId);
    _groups = courseProvider.groups;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectLateDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: _dueDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _lateDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose due date')));
      return;
    }

    if (_lateDueDate != null && _lateDueDate!.isBefore(_dueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Late deadline must be after due date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? attachmentUrl;
    if (_selectedFile != null) {
      final assignmentProvider = Provider.of<AssignmentProvider>(
        context,
        listen: false,
      );
      attachmentUrl = await assignmentProvider.uploadAssignmentFile(
        _selectedFile!.path,
      );

      if (attachmentUrl == null || attachmentUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload attachment')),
          );
        }
        return;
      }
    }

    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    final assignmentData = {
      'course_id': _selectedCourseId,
      'group_id': _selectedGroupId,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'deadline': _dueDate!.toIso8601String(),
      if (_lateDueDate != null)
        'late_deadline': _lateDueDate!.toIso8601String(),
      if (attachmentUrl != null) 'files_url': [attachmentUrl],
    };

    await assignmentProvider.createAssignment(assignmentData);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create assignment successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course *',
                prefixIcon: Icon(Icons.book),
              ),
              isExpanded: true,
              items: [
                for (final course in _courses)
                  DropdownMenuItem(value: course.id, child: Text(course.name)),
              ],
              onChanged: widget.courseId != null
                  ? null
                  : (value) async {
                      setState(() {
                        _selectedCourseId = value;
                        _selectedGroupId = null;
                        _groups = [];
                      });

                      if (value != null) {
                        await _loadGroupsForCourse(value);
                        if (mounted) {
                          setState(() {});
                        }
                      }
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a course';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Group *',
                prefixIcon: Icon(Icons.group_work),
              ),
              isExpanded: true,
              items: [
                for (final group in _groups)
                  DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      group.groupName.isNotEmpty
                          ? group.groupName
                          : 'Group ${group.id}',
                    ),
                  ),
              ],
              onChanged: (_selectedCourseId == null || _groups.isEmpty)
                  ? null
                  : (value) {
                      setState(() {
                        _selectedGroupId = value;
                      });
                    },
              validator: (value) {
                if (_selectedCourseId == null) {
                  return 'Please select a course first';
                }
                if (_groups.isEmpty) {
                  return 'No groups available for this course';
                }
                if (value == null) {
                  return 'Please select a group';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment Title *',
                hintText: 'Enter assignment title',
                prefixIcon: Icon(Icons.assignment),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter assignment title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter assignment description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter assignment description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Due Date *'),
              subtitle: Text(
                _dueDate != null
                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                    : 'Not selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDueDate(context),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: const Text('Late Deadline (optional)'),
              subtitle: Text(
                _lateDueDate != null
                    ? '${_lateDueDate!.day}/${_lateDueDate!.month}/${_lateDueDate!.year} ${_lateDueDate!.hour}:${_lateDueDate!.minute.toString().padLeft(2, '0')}'
                    : 'Not selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectLateDueDate(context),
            ),
            const Divider(),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Attachment',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        pickFile();
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                    ),

                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Selected: $_selectedFileName",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveAssignment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
