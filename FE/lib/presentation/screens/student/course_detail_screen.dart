import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/forum_model.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/instructor_student_provider.dart';
import 'student_submit_assignment_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isReadOnly;

  @override
  void initState() {
    super.initState();
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final semesters = courseProvider.semesters;
    final currentSemesterId =
        semesters.isNotEmpty ? semesters.last.id : widget.course.semesterId;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isStudent = authProvider.userRole == 'student';

    _isReadOnly = isStudent && currentSemesterId != widget.course.semesterId;

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stream'),
            Tab(text: 'Classwork'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(course: widget.course),
          _ClassworkTab(
            courseId: widget.course.id,
            isReadOnly: _isReadOnly,
          ),
          _PeopleTab(course: widget.course),
        ],
      ),
    );
  }
}

class _QuizzesTab extends StatefulWidget {
  final int courseId;
  final bool isReadOnly;

  const _QuizzesTab({required this.courseId, required this.isReadOnly});

  @override
  State<_QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends State<_QuizzesTab> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    // todo call QuizProvider.loadCourseQuizzes(courseId)
    await quizProvider.loadCourseQuizzes(widget.courseId);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final quizzes = quizProvider.quizzes;

        if (_isLoading && quizzes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizzes.isEmpty) {
          return Center(
            child: Text(
              'No quizzes yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadQuizzes,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final isAvailable = quiz.isAvailable;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.quiz,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(quiz.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (quiz.description != null)
                        Text(
                          quiz.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${quiz.duration} min | Attempts: ${quiz.numberOfAttempts}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(isAvailable ? 'Available' : 'Closed'),
                    backgroundColor: (isAvailable
                            ? AppTheme.successColor
                            : AppTheme.warningColor)
                        .withOpacity(0.15),
                  ),
                  onTap: () {
                    if (widget.isReadOnly) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This course belongs to a past semester; quizzes are read-only.',
                          ),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz attempt screen is under development'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatefulWidget {
  final CourseModel course;

  const _OverviewTab({required this.course});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  bool _isLoadingAnnouncements = false;
  List<AnnouncementModel> _announcements = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAnnouncements();
    });
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoadingAnnouncements = true;
    });

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    // todo call ForumProvider.loadCourseAnnouncements(course.id)
    await forumProvider.loadCourseAnnouncements(widget.course.id);

    setState(() {
      _announcements = forumProvider.announcements;
      _isLoadingAnnouncements = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Instructor',
                    value: course.instructorName ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Semester',
                    value: course.semesterName ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.class_,
                    label: 'Sessions',
                    value: '${course.numberOfSessions} lesson',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (course.description != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Announcements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_isLoadingAnnouncements)
            const Center(child: CircularProgressIndicator())
          else if (_announcements.isEmpty)
            Text(
              'No announcements yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            )
          else
            Column(
              children: [
                for (final ann in _announcements)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.announcement,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(ann.title),
                      subtitle: Text(
                        ann.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialsTab extends StatefulWidget {
  final int courseId;

  const _MaterialsTab({required this.courseId});

  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  bool _isLoading = false;
  List<LearningContentModel> _content = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadContent();
    });
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.loadCourseContent(courseId)
    await courseProvider.loadCourseContent(widget.courseId);

    setState(() {
      _content = courseProvider.content;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _content.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_content.isEmpty) {
      return Center(
        child: Text(
          'No materials yet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _content.length,
        itemBuilder: (context, index) {
          final item = _content[index];

          IconData icon;
          switch (item.contentType) {
            case 'video':
              icon = Icons.play_circle_fill;
              break;
            case 'slide':
              icon = Icons.slideshow;
              break;
            case 'link':
              icon = Icons.link;
              break;
            default:
              icon = Icons.description;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              title: Text(item.title),
              subtitle: Text(
                'Session ${item.sessionNumber} · ${item.contentTypeDisplay}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // open material viewer if implemented
              },
            ),
          );
        },
      ),
    );
  }
}

class _AssignmentsTab extends StatefulWidget {
  final int courseId;
  final bool isReadOnly;

  const _AssignmentsTab({required this.courseId, required this.isReadOnly});

  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab> {
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

    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);

    // todo call AssignmentProvider.loadCourseAssignments(courseId)
    await assignmentProvider.loadCourseAssignments(widget.courseId);

    setState(() {
      _assignments = assignmentProvider.assignments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _assignments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty) {
      return Center(
        child: Text(
          'No assignments for this course',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final assignment = _assignments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                child:
                    const Icon(Icons.assignment, color: AppTheme.accentColor),
              ),
              title: Text(assignment.title),
              subtitle: Text(
                'Deadline: ${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                if (widget.isReadOnly) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This course belongs to a past semester; submissions are read-only.',
                      ),
                    ),
                  );
                  return;
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentSubmitAssignmentScreen(
                      assignment: assignment,
                    ),
                  ),
                );
                await _loadAssignments();
              },
            ),
          );
        },
      ),
    );
  }
}

class _ClassworkTab extends StatelessWidget {
  final int courseId;
  final bool isReadOnly;

  const _ClassworkTab({required this.courseId, required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Materials'),
              Tab(text: 'Assignments'),
              Tab(text: 'Quizzes'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                _MaterialsTab(courseId: courseId),
                _AssignmentsTab(courseId: courseId, isReadOnly: isReadOnly),
                _QuizzesTab(courseId: courseId, isReadOnly: isReadOnly),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleTab extends StatefulWidget {
  final CourseModel course;

  const _PeopleTab({required this.course});

  @override
  State<_PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<_PeopleTab> {
  bool _isLoading = false;
  List<GroupModel> _groups = [];
  List<UserModel> _students = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourseGroups(widget.course.id);
    final groups = courseProvider.groups;

    List<UserModel> students = [];
    try {
      final instructorStudentProvider =
          Provider.of<InstructorStudentProvider>(context, listen: false);
      await instructorStudentProvider.loadStudentsInCourse(widget.course.id);
      students = instructorStudentProvider.students;
    } catch (_) {}

    setState(() {
      _groups = groups;
      _students = students;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Groups',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_groups.isEmpty)
            Text(
              'No groups for this course yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            )
          else
            ..._groups.map(
              (group) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.group,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    group.groupName.isNotEmpty
                        ? group.groupName
                        : 'Group ${group.id}',
                  ),
                  subtitle: Text(
                    '${group.students} students',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Students',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_students.isEmpty)
            Text(
              'No students data available',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            )
          else
            ..._students.map(
              (student) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      (student.fullname.isNotEmpty
                              ? student.fullname[0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  title: Text(student.fullname),
                  subtitle: Text(student.email),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
