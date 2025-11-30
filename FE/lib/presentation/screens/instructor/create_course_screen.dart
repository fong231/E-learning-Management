import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberOfSessionsController = TextEditingController();
  
  int? _selectedSemesterId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _numberOfSessionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Call API to create course
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create course successfully!')),
      );
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name *',
                hintText: 'Enter course name',
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter course description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<int>(
              value: _selectedSemesterId,
              decoration: const InputDecoration(
                labelText: 'Semester *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text('HK1 2024-2025')),
                DropdownMenuItem(value: 2, child: Text('HK2 2024-2025')),
                DropdownMenuItem(value: 3, child: Text('HK3 2024-2025')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSemesterId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select semester';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _numberOfSessionsController,
              decoration: const InputDecoration(
                labelText: 'Number of Sessions *',
                hintText: 'Enter number of sessions',
                prefixIcon: Icon(Icons.class_),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of sessions';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : 'No date selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context, true),
            ),
            const Divider(),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: const Text('End Date'),
              subtitle: Text(
                _endDate != null
                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                    : 'No date selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCourse,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Course'),
            ),
          ],
        ),
      ),
    );
  }
}

