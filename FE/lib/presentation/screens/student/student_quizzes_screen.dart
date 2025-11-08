import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StudentQuizzesScreen extends StatelessWidget {
  const StudentQuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài kiểm tra'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                child: const Icon(Icons.quiz, color: AppTheme.secondaryColor),
              ),
              title: Text('Bài kiểm tra ${index + 1}'),
              subtitle: Text('Thời gian: 30 phút • ${index + 10} câu hỏi'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Làm bài'),
              ),
            ),
          );
        },
      ),
    );
  }
}

