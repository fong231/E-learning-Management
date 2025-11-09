import 'package:flutter/material.dart';

class StudentForumScreen extends StatelessWidget {
  const StudentForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: const Icon(Icons.forum, color: Colors.orange),
              ),
              title: Text('Chủ đề thảo luận ${index + 1}'),
              subtitle: Text('Người tạo: Sinh viên ${index + 1} • ${index + 5} phản hồi'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Tạo chủ đề'),
      ),
    );
  }
}

