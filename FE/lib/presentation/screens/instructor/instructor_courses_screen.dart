import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'create_course_screen.dart';

class InstructorCoursesScreen extends StatelessWidget {
  const InstructorCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.book, color: AppTheme.primaryColor),
              ),
              title: Text('Course ${index + 1}'),
              subtitle: Text(
                '${(index + 1) * 20} students • ${index + 10} assignments',
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'students',
                    child: Text('Students List'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateCourseScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Course'),
      ),
    );
  }
}
