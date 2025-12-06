import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/instructor_student_provider.dart';
import '../student/student_chat_screen.dart';
import 'create_student_screen.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key, this.filter, this.courseId});

  final String? filter;
  final int? courseId;

  @override
  State<InstructorStudentsScreen> createState() =>
      _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState extends State<InstructorStudentsScreen> {
  bool _isLoading = false;
  List<UserModel> _students = [];
  List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStudents();
      if (widget.courseId != null) {
        await _loadGroups();
      }
    });
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final instructorStudentProvider = Provider.of<InstructorStudentProvider>(
      context,
      listen: false,
    );

    if (widget.courseId != null) {
      // todo call InstructorStudentProvider.loadStudentsInCourse(courseId)
      await instructorStudentProvider.loadStudentsInCourse(widget.courseId!);
    } else {
      // todo call InstructorStudentProvider.loadInstructorStudents()
      await instructorStudentProvider.loadInstructorStudents();
    }

    _students = instructorStudentProvider.students;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGroups() async {
    if (widget.courseId == null) return;

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.loadCourseGroups(courseId)
    await courseProvider.loadCourseGroups(widget.courseId!);

    setState(() {
      _groups = courseProvider.groups;
    });
  }

  Future<void> _showAssignGroupDialog(UserModel student) async {
    if (widget.courseId == null) return;

    if (_groups.isEmpty) {
      await _loadGroups();
    }

    if (_groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create groups for this course first'),
        ),
      );
      return;
    }

    final selectedGroupId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Assign ${student.fullname} to group'),
        children: [
          for (int i = 0; i < _groups.length; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(_groups[i].id),
              child: Text(
                _groups[i].groupName.isNotEmpty
                    ? _groups[i].groupName
                    : 'Group ${i + 1}',
              ),
            ),
        ],
      ),
    );

    if (selectedGroupId == null) return;

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.enrollStudentToGroup(student.id, groupId)
    await courseProvider.enrollStudentToGroup(student.id, selectedGroupId);

    await _loadGroups();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned ${student.fullname} to group')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: _students.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No students yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                              child: Image.network(
                                student.avatar ??
                                    'https://ui-avatars.com/api/?name=${Uri.encodeFull(student.fullname ?? '')}&background=random&color=fff&format=png',
                              ),
                            ),
                            title: Text(student.fullname),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.email),
                                if (widget.courseId != null)
                                  Text(
                                    student.groupName != null &&
                                            student.groupName!.isNotEmpty
                                        ? 'Group: ${student.groupName}'
                                        : 'Group: Not assigned',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                              ],
                            ),
                            trailing: widget.courseId != null
                                ? IconButton(
                                    icon: const Icon(Icons.group_add),
                                    onPressed: () =>
                                        _showAssignGroupDialog(student),
                                  )
                                : IconButton(
                                    icon:
                                        const Icon(Icons.message_outlined),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => StudentChatScreen(
                                            otherUserId: student.id,
                                            otherUserName: student.fullname,
                                            otherUserRole: student.role,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: widget.courseId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CreateStudentScreen(
                      courseId: widget.courseId!,
                    ),
                  ),
                );

                if (created == true) {
                  await _loadStudents();
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Student'),
            )
          : null,
    );
  }
}
