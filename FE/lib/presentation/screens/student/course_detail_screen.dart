import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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
            Tab(text: 'Tổng quan'),
            Tab(text: 'Tài liệu'),
            Tab(text: 'Bài tập'),
            Tab(text: 'Thảo luận'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(course: widget.course),
          _MaterialsTab(courseId: widget.course.id),
          _AssignmentsTab(courseId: widget.course.id),
          _DiscussionTab(courseId: widget.course.id),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final CourseModel course;

  const _OverviewTab({required this.course});

  @override
  Widget build(BuildContext context) {
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
                    'Thông tin khóa học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Giảng viên',
                    value: course.instructorName ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Học kỳ',
                    value: course.semesterName ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.class_,
                    label: 'Số buổi học',
                    value: '${course.numberOfSessions} buổi',
                  ),
                  if (course.startDate != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.event,
                      label: 'Bắt đầu',
                      value: '${course.startDate!.day}/${course.startDate!.month}/${course.startDate!.year}',
                    ),
                  ],
                  if (course.endDate != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.event_available,
                      label: 'Kết thúc',
                      value: '${course.endDate!.day}/${course.endDate!.month}/${course.endDate!.year}',
                    ),
                  ],
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
                      'Mô tả',
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
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  final int courseId;

  const _MaterialsTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.description, color: AppTheme.primaryColor),
            ),
            title: Text('Bài giảng ${index + 1}'),
            subtitle: Text('Buổi ${index + 1}'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // TODO: Open material
            },
          ),
        );
      },
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  final int courseId;

  const _AssignmentsTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentColor.withOpacity(0.1),
              child: const Icon(Icons.assignment, color: AppTheme.accentColor),
            ),
            title: Text('Bài tập ${index + 1}'),
            subtitle: Text('Hạn nộp: ${DateTime.now().add(Duration(days: index + 1)).day}/${DateTime.now().month}'),
            trailing: Chip(
              label: const Text('Chưa nộp'),
              backgroundColor: AppTheme.warningColor.withOpacity(0.2),
            ),
            onTap: () {
              // TODO: Open assignment
            },
          ),
        );
      },
    );
  }
}

class _DiscussionTab extends StatelessWidget {
  final int courseId;

  const _DiscussionTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.forum, color: Colors.orange),
            ),
            title: Text('Chủ đề thảo luận ${index + 1}'),
            subtitle: Text('${index + 5} phản hồi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open discussion
            },
          ),
        );
      },
    );
  }
}

