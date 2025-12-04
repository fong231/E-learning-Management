import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/forum_provider.dart';
class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int? _selectedCourseId;
  int? _selectedGroupId;
  bool _isLoading = false;
  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    await courseProvider.loadSemesters();

    if (courseProvider.semesters.isNotEmpty) {
      final SemesterModel semester = courseProvider.semesters.last;
      await courseProvider.loadInstructorCoursesWithSemester(semester.id);
      _courses = courseProvider.courses;
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    await forumProvider.createAnnouncement({
      'course_id': _selectedCourseId,
      'group_id': _selectedGroupId,
      'title': _titleController.text,
      'content': _contentController.text,
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create announcement successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
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
              items: [
                for (final course in _courses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.name),
                  ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedCourseId = value;
                  _selectedGroupId = null;
                  _groups = [];
                });

                if (value != null) {
                  await _loadGroupsForCourse(value);
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
                labelText: 'Group',
                prefixIcon: Icon(Icons.group_work),
              ),
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
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter announcement title',
                prefixIcon: Icon(Icons.announcement),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter announcement title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content *',
                hintText: 'Enter announcement content',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter announcement content';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveAnnouncement,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}

