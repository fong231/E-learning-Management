import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/course_model.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import 'student_submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  bool _isLoading = false;
  List<AssignmentModel> _assignments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAssignments();
    });
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);

    final studentId = authProvider.userId;
    if (studentId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Load current semester courses for student
    // todo call CourseProvider.loadSemesters() and CourseProvider.loadStudentCoursesWithSemester(semesterId)
    await courseProvider.loadSemesters();

    List<CourseModel> courses = [];
    if (courseProvider.semesters.isNotEmpty) {
      final SemesterModel semester = courseProvider.semesters.last;
      await courseProvider.loadStudentCoursesWithSemester(semester.id);
      courses = courseProvider.courses;
    }

    final courseIds = courses.map((c) => c.id).toList();

    // Load only pending assignments for this student
    await assignmentProvider.loadPendingAssignmentsForStudent(
      studentId,
      courseIds,
    );

    _assignments = assignmentProvider.assignments;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No assignments yet',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _assignments[index];
                      return _AssignmentCard(
                        assignment: assignment,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StudentSubmitAssignmentScreen(
                                assignment: assignment,
                              ),
                            ),
                          );
                          await _loadAssignments();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor.withOpacity(0.1),
          child: const Icon(Icons.assignment, color: AppTheme.accentColor),
        ),
        title: Text(assignment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (assignment.courseName != null)
              Text(
                assignment.courseName!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondaryColor),
              ),
            const SizedBox(height: 4),
            Text(
              'Deadline: ${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}',
            ),
          ],
        ),
        trailing: Chip(
          label: const Text('Not Submitted'),
          backgroundColor: AppTheme.warningColor.withOpacity(0.2),
        ),
        onTap: onTap,
      ),
    );
  }
}

