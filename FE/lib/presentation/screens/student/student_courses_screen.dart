import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';
import 'course_detail_screen.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
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
    setState(() {
      _isLoading = true;
    });

    if (_selectedSemesterId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // todo call CourseProvider.loadStudentCoursesWithSemester(semesterId)
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadStudentCoursesWithSemester(_selectedSemesterId!);

    _courses = courseProvider.courses;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search is under development'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedSemesterId,
            items: [
              for (final semester in _semesters)
                DropdownMenuItem(value: semester.id, child: Text(semester.description)),
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
            validator: (value) {
              if (value == null) {
                return 'Please select semester';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadCoursesWithSemester();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return _CourseCard(course: course);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.instructorName ?? 'Instructor',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (course.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  course.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: course.semesterName ?? 'Semester',
                  ),
                  _InfoChip(
                    icon: Icons.class_,
                    label: '${course.numberOfSessions} lesson',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

