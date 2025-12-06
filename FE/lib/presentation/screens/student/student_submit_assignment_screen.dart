import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_constants.dart';
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
  bool _isUploading = false;
  String? _selectedFileName;
  String? _uploadedFileUrl;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = result.files.single;
    final path = file.path!;
    final extension = (file.extension ?? '').toLowerCase();

    if (!AppConstants.allowedFileTypes.contains(extension)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid file type. Allowed: ${AppConstants.allowedFileTypes.join(', ')}',
          ),
        ),
      );
      return;
    }

    if (file.size > AppConstants.maxFileSize) {
      if (!mounted) return;
      final maxMb = AppConstants.maxFileSize ~/ (1024 * 1024);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File is too large. Maximum size is ${maxMb}MB'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _selectedFileName = file.name;
    });

    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);

    final url = await assignmentProvider.uploadAssignmentFile(path);

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _uploadedFileUrl = url;
    });

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload file')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully')),
      );
    }
  }

  Future<void> _submit() async {
    if (_uploadedFileUrl == null || _uploadedFileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a file before submitting')),
      );
      return;
    }

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
      'file_url': _uploadedFileUrl,
    };

    await assignmentProvider.submitAssignment(submissionData);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final error = assignmentProvider.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assignment: $error')),
      );
      return;
    }

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
            Text(
              'Attachment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFileName ?? 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadFile,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file),
                  label: Text(_isUploading ? 'Uploading...' : 'Choose File'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Allowed types: ${AppConstants.allowedFileTypes.join(', ')} · Max ${(AppConstants.maxFileSize ~/ (1024 * 1024))}MB',
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
