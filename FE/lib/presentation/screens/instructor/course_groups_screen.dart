import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';

class CourseGroupsScreen extends StatefulWidget {
  const CourseGroupsScreen({super.key, required this.course});

  final CourseModel course;

  @override
  State<CourseGroupsScreen> createState() => _CourseGroupsScreenState();
}

class _CourseGroupsScreenState extends State<CourseGroupsScreen> {
  bool _isLoading = false;
  List<GroupModel> _groups = [];
  final TextEditingController _groupCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGroups();
    });
  }

  @override
  void dispose() {
    _groupCountController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.loadCourseGroups(courseId)
    await courseProvider.loadCourseGroups(widget.course.id);
    _groups = courseProvider.groups;

    if (_groups.isNotEmpty) {
      _groupCountController.text = _groups.length.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateGroups() async {
    final desiredStr = _groupCountController.text.trim();
    final desiredCount = int.tryParse(desiredStr) ?? 0;

    if (desiredCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of groups')),
      );
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    // Create additional groups until reaching desired count
    while (_groups.length < desiredCount) {
      // todo call CourseProvider.createGroup(courseId)
      await courseProvider.createGroup(widget.course.id);
      _groups = courseProvider.groups;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups - ${widget.course.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Configuration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how many groups this course should have. New groups will be created as needed.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _groupCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of groups',
                prefixIcon: Icon(Icons.group_work),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateGroups,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Groups'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Existing Groups',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No groups yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.group,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                title: Text(group.groupName.isNotEmpty
                                    ? group.groupName
                                    : 'Group ${index + 1}'),
                                subtitle: Text(
                                  '${group.students} students',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
