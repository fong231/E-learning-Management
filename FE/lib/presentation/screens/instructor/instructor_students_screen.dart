import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InstructorStudentsScreen extends StatelessWidget {
  const InstructorStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                child: Text('SV${index + 1}'),
              ),
              title: Text('Sinh viên ${index + 1}'),
              subtitle: Text('MSSV: 2024${(index + 1).toString().padLeft(4, '0')}'),
              trailing: IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

