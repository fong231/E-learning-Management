import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/instructor_student_provider.dart';
import 'create_course_screen.dart';
import 'instructor_students_screen.dart';
import 'course_groups_screen.dart';
import 'create_assignment_screen.dart';
import 'create_quiz_screen.dart';

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
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadSemesters();
    _semesters = courseProvider.semesters;

    if (_semesters.isNotEmpty) {
      _selectedSemesterId =
          courseProvider.selectedSemesterId ?? _semesters.last.id;
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
      body: Column(
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
                  if (value == null) return;

                  setState(() {
                    _selectedSemesterId = value;
                  });

                  final courseProvider =
                      Provider.of<CourseProvider>(context, listen: false);
                  await courseProvider.setSelectedSemester(value);

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          );

          if (created == true) {
            if (!mounted) return;
            await _loadCoursesWithSemester();
          }
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _InstructorCourseDetailScreen(course: course),
            ),
          );
        },
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

class _InstructorCourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const _InstructorCourseDetailScreen({required this.course});

  @override
  State<_InstructorCourseDetailScreen> createState() => _InstructorCourseDetailScreenState();
}

class _InstructorCourseDetailScreenState extends State<_InstructorCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${course.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Materials'),
            Tab(text: 'Assignments'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InstructorMaterialsTab(courseId: course.id),
          _InstructorAssignmentsTab(courseId: course.id),
          _InstructorQuizzesTab(courseId: course.id),
        ],
      ),
    );
  }
}

class _InstructorMaterialsTab extends StatefulWidget {
  final int courseId;

  const _InstructorMaterialsTab({required this.courseId});

  @override
  State<_InstructorMaterialsTab> createState() => _InstructorMaterialsTabState();
}

class _InstructorMaterialsTabState extends State<_InstructorMaterialsTab> {
  bool _isLoading = false;
  List<LearningContentModel> _content = [];
  bool _isUploading = false;

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
    await courseProvider.loadCourseContent(widget.courseId);

    if (!mounted) return;

    setState(() {
      _content = courseProvider.content;
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadMaterial() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    try {
      await courseProvider.uploadCourseMaterialFile(
        widget.courseId,
        result.files.single.path!,
      );

      if (!mounted) return;

      await _loadContent();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload material: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String? _buildContentUrl(LearningContentModel item) {
    final raw = item.contentUrl;
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    return "${AppConstants.baseUrl}$raw";
  }

  Future<void> _openMaterial(LearningContentModel item) async {
    final urlStr = _buildContentUrl(item);
    if (urlStr == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file attached for this material.')),
      );
      return;
    }

    final uri = Uri.tryParse(urlStr);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid material URL.')),
      );
      return;
    }

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open material URL.')),
        );
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open material.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_isLoading && _content.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_content.isEmpty) {
      body = Center(
        child: Text(
          'No materials yet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadContent,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _content.length,
          itemBuilder: (context, index) {
            final item = _content[index];
            final contentUrl = _buildContentUrl(item);
            final fileName = contentUrl != null
                ? Uri.parse(contentUrl).path.split('/').last
                : null;

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session ${item.sessionNumber} · ${item.contentTypeDisplay}',
                    ),
                    if (fileName != null && fileName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          fileName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _openMaterial(item);
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadMaterial,
        icon: _isUploading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_file),
        label: Text(_isUploading ? 'Uploading...' : 'Upload Material'),
      ),
    );
  }
}

class _InstructorAssignmentsTab extends StatefulWidget {
  final int courseId;

  const _InstructorAssignmentsTab({required this.courseId});

  @override
  State<_InstructorAssignmentsTab> createState() => _InstructorAssignmentsTabState();
}

class _InstructorAssignmentsTabState extends State<_InstructorAssignmentsTab> {
  bool _isLoading = false;

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
    });

    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);
    await assignmentProvider.loadCourseAssignments(widget.courseId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AssignmentProvider>(
        builder: (context, assignmentProvider, child) {
          final assignments = List.of(assignmentProvider.assignments)
            ..sort((a, b) => b.deadline.compareTo(a.deadline));

          if (_isLoading && assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (assignments.isEmpty) {
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
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.accentColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.assignment,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    title: Text(assignment.title),
                    subtitle: Text(
                      'Deadline: ${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Assignment'),
                            content: const Text(
                              'Are you sure you want to delete this assignment?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await assignmentProvider.deleteAssignment(
                            assignment.id,
                          );
                          if (mounted) {
                            await _loadAssignments();
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateAssignmentScreen(courseId: widget.courseId),
            ),
          );
          if (mounted) {
            await _loadAssignments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Assignment'),
      ),
    );
  }
}

class _InstructorQuizzesTab extends StatefulWidget {
  final int courseId;

  const _InstructorQuizzesTab({required this.courseId});

  @override
  State<_InstructorQuizzesTab> createState() => _InstructorQuizzesTabState();
}

class _InstructorQuizzesTabState extends State<_InstructorQuizzesTab> {
  bool _isLoading = false;

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.loadCourseQuizzes(widget.courseId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuizProvider>(
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryColor.withOpacity(0.1),
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _QuizStatsScreen(quiz: quiz),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Quiz'),
                            content: const Text(
                              'Are you sure you want to delete this quiz?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await quizProvider.deleteQuiz(quiz.id);
                          if (mounted) {
                            await _loadQuizzes();
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateQuizScreen(courseId: widget.courseId),
            ),
          );
          if (mounted) {
            await _loadQuizzes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
      ),
    );
  }
}

class _QuizStatsScreen extends StatefulWidget {
  final QuizModel quiz;

  const _QuizStatsScreen({required this.quiz});

  @override
  State<_QuizStatsScreen> createState() => _QuizStatsScreenState();
}

class _QuizStatsScreenState extends State<_QuizStatsScreen> {
  bool _isLoading = false;
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

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final instructorStudentProvider =
        Provider.of<InstructorStudentProvider>(context, listen: false);

    try {
      await Future.wait([
        quizProvider.loadQuizAttempts(widget.quiz.id),
        instructorStudentProvider.loadStudentsInCourse(widget.quiz.courseId),
      ]);
    } catch (_) {
      // errors will be reflected via providers if needed
    }

    if (!mounted) return;

    setState(() {
      _students = instructorStudentProvider.students;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats: ${widget.quiz.title}'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final attempts = quizProvider.attempts
              .where((a) => a.quizId == widget.quiz.id)
              .toList();

          final instructorStudentProvider =
              Provider.of<InstructorStudentProvider>(context);
          final students = _students.isNotEmpty
              ? _students
              : instructorStudentProvider.students;

          if (_isLoading && attempts.isEmpty && students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // If student list is not available for some reason, fall back to
          // attempt-based view (only students who attempted).
          if (students.isEmpty) {
            if (attempts.isEmpty) {
              return Center(
                child: Text(
                  'No attempts yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }

            final Map<int, List<QuizAttemptModel>> attemptsByStudent = {};
            for (final attempt in attempts) {
              attemptsByStudent
                  .putIfAbsent(attempt.studentId, () => [])
                  .add(attempt);
            }

            final entries = attemptsByStudent.entries.toList()
              ..sort((a, b) {
                final nameA = a.value.first.studentName ??
                    'Student ${a.value.first.studentId}';
                final nameB = b.value.first.studentName ??
                    'Student ${b.value.first.studentId}';
                return nameA.compareTo(nameB);
              });

            final totalStudents = entries.length;
            final totalAttempts = attempts.length;
            final completedAttempts =
                attempts.where((a) => a.isCompleted).length;

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Students attempted: $totalStudents'),
                            Text('Total attempts: $totalAttempts'),
                            Text('Completed attempts: $completedAttempts'),
                          ],
                        ),
                      ),
                    );
                  }

                  final entry = entries[index - 1];
                  final studentAttempts = entry.value;
                  final completedForStudent = studentAttempts
                      .where((a) => a.isCompleted)
                      .toList();

                  double? bestScore;
                  if (completedForStudent.isNotEmpty) {
                    for (final a in completedForStudent) {
                      final s = a.score ?? 0;
                      if (bestScore == null || s > bestScore!) {
                        bestScore = s;
                      }
                    }
                  }

                  DateTime? lastCompletedAt;
                  for (final a in completedForStudent) {
                    if (a.completedAt == null) continue;
                    if (lastCompletedAt == null ||
                        a.completedAt!.isAfter(lastCompletedAt)) {
                      lastCompletedAt = a.completedAt;
                    }
                  }

                  final name = studentAttempts.first.studentName ??
                      'Student ${studentAttempts.first.studentId}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.accentColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attempts: ${studentAttempts.length}'
                            '${completedForStudent.isEmpty ? '' : ' · Completed: ${completedForStudent.length}'}',
                          ),
                          if (bestScore != null)
                            Text(
                              'Best score: ${bestScore!.toStringAsFixed(1)}',
                            ),
                          if (lastCompletedAt != null)
                            Text(
                              'Last submission: ${lastCompletedAt.day}/${lastCompletedAt.month}/${lastCompletedAt.year} '
                              '${lastCompletedAt.hour.toString().padLeft(2, '0')}:${lastCompletedAt.minute.toString().padLeft(2, '0')}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Normal path: we have the full student list for this course.
          final Map<int, List<QuizAttemptModel>> attemptsByStudent = {};
          for (final attempt in attempts) {
            attemptsByStudent
                .putIfAbsent(attempt.studentId, () => [])
                .add(attempt);
          }

          final sortedStudents = List<UserModel>.from(students)
            ..sort((a, b) => a.fullname.compareTo(b.fullname));

          final totalStudents = sortedStudents.length;
          final studentsAttempted =
              attemptsByStudent.entries.where((e) => e.value.isNotEmpty).length;
          final totalAttempts = attempts.length;
          final completedAttempts =
              attempts.where((a) => a.isCompleted).length;
          final studentsCompleted = attemptsByStudent.entries
              .where((e) => e.value.any((a) => a.isCompleted))
              .length;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedStudents.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Total students: $totalStudents'),
                          Text('Students attempted: $studentsAttempted'),
                          Text('Students completed: $studentsCompleted'),
                          Text('Total attempts: $totalAttempts'),
                          Text('Completed attempts: $completedAttempts'),
                        ],
                      ),
                    ),
                  );
                }

                final student = sortedStudents[index - 1];
                final studentAttempts =
                    attemptsByStudent[student.id] ?? const <QuizAttemptModel>[];
                final completedForStudent = studentAttempts
                    .where((a) => a.isCompleted)
                    .toList();

                double? bestScore;
                if (completedForStudent.isNotEmpty) {
                  for (final a in completedForStudent) {
                    final s = a.score ?? 0;
                    if (bestScore == null || s > bestScore!) {
                      bestScore = s;
                    }
                  }
                }

                DateTime? lastCompletedAt;
                for (final a in completedForStudent) {
                  if (a.completedAt == null) continue;
                  if (lastCompletedAt == null ||
                      a.completedAt!.isAfter(lastCompletedAt)) {
                    lastCompletedAt = a.completedAt;
                  }
                }

                final groupLabel = student.groupName ??
                    (student.groupId != null
                        ? 'Group ${student.groupId}'
                        : null);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.accentColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    title: Text(student.fullname),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.email),
                        if (groupLabel != null)
                          Text(
                            groupLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppTheme.textSecondaryColor),
                          ),
                        const SizedBox(height: 4),
                        if (studentAttempts.isEmpty)
                          Text(
                            'Status: Not attempted',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppTheme.textSecondaryColor),
                          )
                        else
                          Text(
                            'Attempts: ${studentAttempts.length}'
                            '${completedForStudent.isEmpty ? '' : ' · Completed: ${completedForStudent.length}'}',
                          ),
                        if (bestScore != null)
                          Text(
                            'Best score: ${bestScore!.toStringAsFixed(1)}',
                          ),
                        if (lastCompletedAt != null)
                          Text(
                            'Last submission: ${lastCompletedAt.day}/${lastCompletedAt.month}/${lastCompletedAt.year} '
                            '${lastCompletedAt.hour.toString().padLeft(2, '0')}:${lastCompletedAt.minute.toString().padLeft(2, '0')}',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
