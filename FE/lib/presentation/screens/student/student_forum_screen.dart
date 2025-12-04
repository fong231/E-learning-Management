import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/forum_model.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/forum_provider.dart';
import 'student_topic_chat_screen.dart';

class StudentForumScreen extends StatefulWidget {
  const StudentForumScreen({super.key});

  @override
  State<StudentForumScreen> createState() => _StudentForumScreenState();
}

class _StudentForumScreenState extends State<StudentForumScreen> {
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

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

    // Load topics for all enrolled courses
    // todo call ForumProvider.loadTopicsForCourses(courseIds)
    await forumProvider.loadTopicsForCourses(courseIds);

    _topics = forumProvider.topics;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
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
                          subtitle: Text(
                            '${topic.courseName ?? 'Course'}  ${topic.replyCount} replies',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create topic screen is under development'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Topic'),
      ),
    );
  }
}

