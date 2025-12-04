import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';
import 'create_course_screen.dart';
import 'instructor_students_screen.dart';
import 'course_groups_screen.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() => _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  bool _isLoading = false;
  List<CourseModel> _courses = [];
  List<SemesterModel> _semesters = [];
  int? _selectedSemesterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSemesters();
      await _loadCoursesWithSemester();
    });
  }

  Future<void> _loadSemesters() async {
    setState(() {
      _isLoading = true;
    });

    // todo call CourseProvider.loadSemesters()
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadSemesters();
    _semesters = courseProvider.semesters;

    if (_semesters.isNotEmpty) {
      // default to nearest (last) semester
      _selectedSemesterId = _semesters.last.id;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCoursesWithSemester() async {
    if (_selectedSemesterId == null) return;

    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.loadInstructorCoursesWithSemester(semesterId)
    await courseProvider.loadInstructorCoursesWithSemester(_selectedSemesterId!);
    _courses = courseProvider.courses;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.deleteCourse(course.id)
    await courseProvider.deleteCourse(course.id);
    await _loadCoursesWithSemester();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_semesters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  value: _selectedSemesterId,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: [
                    for (final semester in _semesters)
                      DropdownMenuItem(
                        value: semester.id,
                        child: Text(semester.description),
                      ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedSemesterId = value;
                    });
                    await _loadCoursesWithSemester();
                  },
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No courses yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadCoursesWithSemester,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _courses.length,
                            itemBuilder: (context, index) {
                              final course = _courses[index];
                              return _InstructorCourseCard(
                                course: course,
                                onDelete: () => _deleteCourse(course),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Course'),
      ),
    );
  }
}

class _InstructorCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onDelete;

  const _InstructorCourseCard({
    required this.course,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(Icons.book, color: AppTheme.primaryColor),
        ),
        title: Text(course.name),
        subtitle: Text(
          course.description ?? 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateCourseScreen(
                    isEdit: true,
                    courseId: course.id,
                    name: course.name,
                    description: course.description,
                    semesterId: course.semesterId,
                    numberOfSessions: course.numberOfSessions,
                  ),
                ),
              );
            } else if (value == 'students') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InstructorStudentsScreen(courseId: course.id),
                ),
              );
            } else if (value == 'groups') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CourseGroupsScreen(course: course),
                ),
              );
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'students', child: Text('Students List')),
            PopupMenuItem(value: 'groups', child: Text('Manage Groups')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
