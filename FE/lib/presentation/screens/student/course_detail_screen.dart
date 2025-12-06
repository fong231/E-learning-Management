import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
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
import 'student_topic_chat_screen.dart';

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

    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'Forum'),
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
          _ForumTab(
            courseId: widget.course.id,
            isReadOnly: _isReadOnly,
          ),
        ],
      ),
    );
  }
}

class _ForumTab extends StatefulWidget {
  final int courseId;
  final bool isReadOnly;

  const _ForumTab({required this.courseId, required this.isReadOnly});

  @override
  State<_ForumTab> createState() => _ForumTabState();
}

class _ForumTabState extends State<_ForumTab> {
  bool _isLoading = false;
  List<TopicModel> _topics = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTopics();
    });
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.loadCourseTopics(widget.courseId);

    setState(() {
      _topics = forumProvider.topics;
      _isLoading = false;
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _showCreateTopicDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != true) return;

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.createTopic({
      'course_id': widget.courseId,
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
    });

    if (!mounted) return;

    final error = forumProvider.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create topic: $error')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Topic created successfully')),
    );

    await _loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? Center(
                  child: Text(
                    'No topics yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTopics,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _topics.length,
                    itemBuilder: (context, index) {
                      final topic = _topics[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.orange.withOpacity(0.1),
                            child: const Icon(Icons.forum, color: Colors.orange),
                          ),
                          title: Text(topic.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${topic.replyCount} replies'),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(topic.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textSecondaryColor),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StudentTopicChatScreen(
                                  topic: topic,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCreateTopicDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Topic'),
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

  Future<void> _handleQuizTap(BuildContext context, quiz) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    final studentId = authProvider.userId;
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine current student.')),
      );
      return;
    }

    try {
      await quizProvider.loadStudentAttempts(quiz.id, studentId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load quiz attempts.')),
      );
      return;
    }

    final attempts = quizProvider.attempts
        .where((a) => a.quizId == quiz.id && a.studentId == studentId)
        .toList();

    final bool isClosed = !quiz.isAvailable;
    final completedAttempts = attempts.where((a) => a.isCompleted).toList();
    final int attemptsUsed = completedAttempts.length;
    final bool attemptsExhausted = attemptsUsed >= quiz.numberOfAttempts;

    if (isClosed || attemptsExhausted) {
      double? bestScore;
      for (final a in completedAttempts) {
        final s = a.score ?? 0;
        if (bestScore == null || s > bestScore) {
          bestScore = s;
        }
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz result'),
          content: Text(
            completedAttempts.isEmpty
                ? 'Quiz is closed or attempts are exhausted. You have no completed attempts.'
                : 'Quiz is closed or attempts are exhausted.\n'
                    'Completed attempts: $attemptsUsed\n'
                    'Best score: ${bestScore?.toStringAsFixed(1) ?? 'N/A'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (attempts.isEmpty) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz status'),
          content: const Text('Not attempted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    double? lastScore;
    if (completedAttempts.isNotEmpty) {
      lastScore = completedAttempts.last.score;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz attempts'),
        content: Text(
          'You have used $attemptsUsed of ${quiz.numberOfAttempts} attempts.'
          '${lastScore != null ? '\nLast score: ${lastScore.toStringAsFixed(1)}' : ''}'
          '\nQuiz attempt screen is under development.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final quizzes = List.of(quizProvider.quizzes)
          ..sort((a, b) {
            final aTime = a.startTime ?? a.createdAt;
            final bTime = b.startTime ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

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
                  onTap: () async {
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

                    await _handleQuizTap(context, quiz);
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
  Set<int> _submittedAssignmentIds = {};

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.userId;

    // Load assignments for this course
    await assignmentProvider.loadCourseAssignments(widget.courseId);

    final loaded = List<AssignmentModel>.from(assignmentProvider.assignments);
    loaded.sort((a, b) => b.deadline.compareTo(a.deadline));

    final submittedIds = <int>{};

    if (studentId != null) {
      for (final assignment in loaded) {
        await assignmentProvider.loadStudentSubmissions(
          assignment.id,
          studentId,
        );

        if (assignmentProvider.submissions.isNotEmpty) {
          submittedIds.add(assignment.id);
        }
      }
    }

    setState(() {
      _assignments = loaded;
      _submittedAssignmentIds = submittedIds;
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
          final isSubmitted = _submittedAssignmentIds.contains(assignment.id);

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(isSubmitted ? 'Submitted' : 'Not submitted'),
                    backgroundColor: (isSubmitted
                            ? AppTheme.successColor
                            : AppTheme.warningColor)
                        .withOpacity(0.15),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
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
  int? _currentUserId;

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
    var groups = courseProvider.groups;

    List<UserModel> students = [];
    try {
      final instructorStudentProvider =
          Provider.of<InstructorStudentProvider>(context, listen: false);
      await instructorStudentProvider.loadStudentsInCourse(widget.course.id);
      students = instructorStudentProvider.students;
    } catch (_) {}

    // Filter to only the group and students that match the current student
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId;
    _currentUserId = currentUserId;
    if (currentUserId != null) {
      int? userGroupId;
      for (final s in students) {
        if (s.id == currentUserId) {
          userGroupId = s.groupId;
          break;
        }
      }

      if (userGroupId != null) {
        groups = groups.where((g) => g.id == userGroupId).toList();
        students = students.where((s) => s.groupId == userGroupId).toList();
      }
    }

    setState(() {
      _groups = groups;
      _students = students;
      _isLoading = false;
    });
  }

  String? _getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return null;
    }

    if (avatarPath.startsWith('https://ui-avatars.com')) {
      return avatarPath;
    }

    return "${AppConstants.baseUrl}/uploads/$avatarPath";
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
              (student) {
                final bool isCurrentUser =
                    _currentUserId != null && student.id == _currentUserId;
                final displayName = isCurrentUser
                    ? '${student.fullname} (you)'
                    : student.fullname;
                final groupLabel =
                    student.groupId != null ? 'Group ${student.groupId}' : null;
                final subtitleText = groupLabel != null
                    ? '${student.email} · $groupLabel'
                    : student.email;
                final avatarUrl = _getAvatarUrl(student.avatar);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              (student.fullname.isNotEmpty
                                      ? student.fullname[0]
                                      : '?')
                                  .toUpperCase(),
                              style:
                                  const TextStyle(color: AppTheme.primaryColor),
                            )
                          : null,
                    ),
                    title: Text(displayName),
                    subtitle: Text(subtitleText),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
