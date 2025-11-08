import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StudentAssignmentsScreen extends StatelessWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
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
                label: Text(index % 2 == 0 ? 'Chưa nộp' : 'Đã nộp'),
                backgroundColor: index % 2 == 0
                    ? AppTheme.warningColor.withOpacity(0.2)
                    : AppTheme.successColor.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }
}

