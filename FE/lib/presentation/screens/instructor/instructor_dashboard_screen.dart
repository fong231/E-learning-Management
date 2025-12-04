import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/instructor_provider.dart';
import 'create_announcement_screen.dart';
import 'create_assignment_screen.dart';
import 'create_course_screen.dart';
import 'create_quiz_screen.dart';
import 'instructor_courses_screen.dart';
import 'instructor_messages_screen.dart';
import 'instructor_profile_screen.dart';
import 'instructor_students_screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InstructorHomeTab(),
    const InstructorCoursesScreen(),
    const InstructorStudentsScreen(),
    const InstructorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Student',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class InstructorHomeTab extends StatefulWidget {
  const InstructorHomeTab({super.key});

  @override
  State<InstructorHomeTab> createState() => _InstructorHomeTabState();
}

class _InstructorHomeTabState extends State<InstructorHomeTab> {
  List<ChartData> chartData = [
    ChartData(name: 'Courses', value: 0, color: Colors.blue),
    ChartData(name: 'Students', value: 0, color: Colors.green),
    ChartData(name: 'Groups', value: 0, color: Colors.orange),
    ChartData(name: 'Assignments', value: 0, color: Colors.purple),
    ChartData(name: 'Quizzes', value: 0, color: Colors.red),
  ];

  List<SemesterModel> _semesters = [];
  int? _selectedSemesterId;
  bool _isLoadingSemesters = false;

  Future<void> _loadSemesters() async {
    setState(() {
      _isLoadingSemesters = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadSemesters();
    final semesters = courseProvider.semesters;

    setState(() {
      _semesters = semesters;
      if (_semesters.isNotEmpty) {
        _selectedSemesterId =
            courseProvider.selectedSemesterId ?? _semesters.last.id;
      } else {
        _selectedSemesterId = null;
      }
      _isLoadingSemesters = false;
    });
  }

  Future<void> loadChartData() async {
    final instructorProvider = Provider.of<InstructorProvider>(
      context,
      listen: false,
    );
    await instructorProvider.loadInstructorSummary(
      semesterId: _selectedSemesterId,
    );

    final summary = instructorProvider.summary;

    setState(() {
      print('summary: ${summary?.totalCourses}');
      chartData[0].value = summary?.totalCourses.toDouble() ?? 0;
      chartData[1].value = summary?.totalStudents.toDouble() ?? 0;
      chartData[2].value = summary?.totalGroups.toDouble() ?? 0;
      chartData[3].value = summary?.totalAssignments.toDouble() ?? 0;
      chartData[4].value = summary?.totalQuizzes.toDouble() ?? 0;
    });
  }

  Future<void> _refreshOverview() async {
    await _loadSemesters();
    await loadChartData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSemesters();
      await loadChartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Overview'),
            actions: [
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InstructorMessagesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshOverview,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.fullname ?? 'Instructor',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to the LMS system',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoadingSemesters)
                    const Center(child: CircularProgressIndicator())
                  else if (_semesters.isNotEmpty) ...[
                    Text(
                      'Semester',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedSemesterId,
                      decoration: const InputDecoration(
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

                        final courseProvider = Provider.of<CourseProvider>(
                          context,
                          listen: false,
                        );
                        await courseProvider.setSelectedSemester(value);

                        await loadChartData();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Statistics
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Biểu đồ dạng cột
                  _CustomBarChart(data: chartData),
                  const SizedBox(height: 24),

                  // Stat Cards - Row 1 (3 card: Courses, Students, Groups)
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.book,
                          title: 'Courses',
                          value: chartData[0].value.toStringAsFixed(0),
                          color: chartData[0].color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people,
                          title: 'Students',
                          value: chartData[1].value.toStringAsFixed(0),
                          color: chartData[1].color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          // NEW CARD: Groups
                          icon: Icons.group_work,
                          title: 'Groups',
                          value: chartData[2].value.toStringAsFixed(0),
                          color: chartData[2].color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stat Cards - Row 2 (2 card: Assignments, Quizzes)
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.assignment,
                          title: 'Assignments',
                          value: chartData[3].value.toStringAsFixed(0),
                          color: chartData[3].color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          title: 'Quizzes',
                          value: chartData[4].value.toStringAsFixed(0),
                          color: chartData[4].color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    title: 'Create New Course',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateCourseScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.assignment_add,
                    title: 'Create New Assignment',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateAssignmentScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.quiz,
                    title: 'Create New Quiz',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateQuizScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.announcement,
                    title: 'Create New Announcement',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateAnnouncementScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Course Management
                  Text(
                    'Course Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _QuickActionButton(
                    icon: Icons.analytics_outlined,
                    title: 'View Grading Reports',
                    onTap: () {
                      // Giả định có màn hình tương ứng
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to Grading Reports'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.settings_applications_outlined,
                    title: 'Manage Course Settings',
                    onTap: () {
                      // Giả định có màn hình tương ứng
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to Course Settings'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recent Activities
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(
                    context,
                    icon: Icons.assignment_turned_in,
                    title: 'Assignment Submitted',
                    subtitle: '5 students have submitted their assignments',
                    time: '1 hour ago',
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    context,
                    icon: Icons.message,
                    title: 'New Message',
                    subtitle: 'Student 123456 has sent a message',
                    time: '3 hours ago',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// Data model cho biểu đồ
class ChartData {
  final String name;
  late double value;
  final Color color;

  ChartData({required this.name, required this.value, required this.color});
}

// Widget Biểu đồ Cột tùy chỉnh sử dụng fl_chart
class _CustomBarChart extends StatelessWidget {
  final List<ChartData> data;

  const _CustomBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    // Giá trị lớn nhất trong dữ liệu để đặt trục Y
    double maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue < 10)
      maxValue = 10; // Đảm bảo trục Y có khoảng nhìn tốt cho các giá trị nhỏ
    maxValue = (maxValue * 1.2).ceilToDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistical Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    ChartData item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.value,
                          color: item.color,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Lấy tên cột dựa vào index
                          String title = data[value.toInt()].name;
                          return SideTitleWidget(
                            space: 8,
                            meta: meta,
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Count'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const Text(
                              '0',
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          if (value == maxValue / 2) {
                            return Text(
                              (maxValue / 2).toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          if (value == maxValue) {
                            return Text(
                              maxValue.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[group.x];
                        return BarTooltipItem(
                          item.value.toStringAsFixed(0),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  minY: 0,
                ),
                swapAnimationDuration: const Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
