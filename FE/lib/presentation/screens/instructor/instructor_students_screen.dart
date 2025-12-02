import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/instructor_student_provider.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key, this.filter});

  final String? filter;

  @override
  State<InstructorStudentsScreen> createState() =>
      _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState extends State<InstructorStudentsScreen> {
  bool _isLoading = false;
  
  List<UserModel> _students = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load students from repository
    final instructorStudentProvider = Provider.of<InstructorStudentProvider>(context, listen: false);
    await instructorStudentProvider.loadInstructorStudents();
    
    _students = instructorStudentProvider.students;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Image.network(student.avatar ?? 'https://ui-avatars.com/api/?name=${Uri.encodeFull(student.fullname ?? '')}&background=random&color=fff'),
                    ),
                    title: Text(student.fullname),
                    subtitle: Text(student.email),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
