import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/assignment_model.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';

class StudentSubmitAssignmentScreen extends StatefulWidget {
  const StudentSubmitAssignmentScreen({
    super.key,
    required this.assignment,
  });

  final AssignmentModel assignment;

  @override
  State<StudentSubmitAssignmentScreen> createState() =>
      _StudentSubmitAssignmentScreenState();
}

class _StudentSubmitAssignmentScreenState
    extends State<StudentSubmitAssignmentScreen> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);

    final studentId = authProvider.userId;
    if (studentId == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final submissionData = {
      'assignment_id': widget.assignment.id,
      'student_id': studentId,
    };

    // todo call AssignmentProvider.submitAssignment(submissionData)
    await assignmentProvider.submitAssignment(submissionData);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted successfully')), 
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              assignment.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (assignment.description != null)
              Text(
                assignment.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Text(
              'Deadline: ${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
