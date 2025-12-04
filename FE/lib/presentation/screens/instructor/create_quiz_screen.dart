import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/quiz_provider.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _attemptsController = TextEditingController(text: '1');
  
  int? _selectedCourseId;
  int? _selectedGroupId;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;
  
  final List<QuestionItem> _questions = [];

  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _attemptsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCourses();
    });
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _AddQuestionDialog(
        onAdd: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // todo call CourseProvider.loadSemesters() and CourseProvider.loadInstructorCoursesWithSemester(semesterId)
    await courseProvider.loadSemesters();

    if (courseProvider.semesters.isNotEmpty) {
      final SemesterModel semester = courseProvider.semesters.last;
      await courseProvider.loadInstructorCoursesWithSemester(semester.id);
      _courses = courseProvider.courses;
    } else {
      _courses = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGroupsForCourse(int courseId) async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourseGroups(courseId);
    _groups = courseProvider.groups;
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      final quizData = {
        'course_id': _selectedCourseId,
        'group_id': _selectedGroupId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'duration': int.parse(_durationController.text),
        'number_of_attempts': int.parse(_attemptsController.text),
        'start_time': _startTime?.toIso8601String(),
        'end_time': _endTime?.toIso8601String(),
      };

      // todo call QuizProvider.createQuiz(quizData)
      final createdQuiz = await quizProvider.createQuiz(quizData);

      for (final question in _questions) {
        final questionData = {
          'quiz_id': createdQuiz.id,
          'question_text': question.questionText,
          'question_type': 'multiple_choice',
          'level': question.level,
          'points': question.points,
          'options': question.options,
          'correct_answer': question.correctAnswer,
        };

        // todo call QuizProvider.addQuestion(questionData)
        await quizProvider.addQuestion(questionData);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create quiz successfully!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create quiz: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course *',
                prefixIcon: Icon(Icons.book),
              ),
              items: [
                for (final course in _courses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.name),
                  ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedCourseId = value;
                  _selectedGroupId = null;
                  _groups = [];
                });

                if (value != null) {
                  await _loadGroupsForCourse(value);
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a course';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Group *',
                prefixIcon: Icon(Icons.group_work),
              ),
              items: [
                for (final group in _groups)
                  DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      group.groupName.isNotEmpty
                          ? group.groupName
                          : 'Group ${group.id}',
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a group';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.quiz),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes) *',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter duration';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _attemptsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of attempts *',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of attempts';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Start Time'),
              subtitle: Text(
                _startTime != null
                    ? '${_startTime!.day}/${_startTime!.month}/${_startTime!.year} ${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDateTime(context, true),
            ),
            const Divider(),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: const Text('End Time'),
              subtitle: Text(
                _endTime != null
                    ? '${_endTime!.day}/${_endTime!.month}/${_endTime!.year} ${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDateTime(context, false),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions (${_questions.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(question.questionText),
                  subtitle: Text('Score: ${question.points}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _questions.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _saveQuiz,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionItem {
  final String questionText;
  final double points;
  final String level;
  final List<String> options;
  final String correctAnswer;

  QuestionItem({
    required this.questionText,
    required this.points,
    required this.level,
    required this.options,
    required this.correctAnswer,
  });
}

class _AddQuestionDialog extends StatefulWidget {
  final Function(QuestionItem) onAdd;

  const _AddQuestionDialog({required this.onAdd});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _questionController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  String _selectedLevel = AppConstants.levelEasy;
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  int _correctOptionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Enter question text',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Score',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level',
              ),
              items: const [
                DropdownMenuItem(
                  value: AppConstants.levelEasy,
                  child: Text('Easy'),
                ),
                DropdownMenuItem(
                  value: AppConstants.levelMedium,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: AppConstants.levelHard,
                  child: Text('Hard'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _optionAController,
              decoration: const InputDecoration(
                labelText: 'Option A',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _optionBController,
              decoration: const InputDecoration(
                labelText: 'Option B',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _optionCController,
              decoration: const InputDecoration(
                labelText: 'Option C',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _optionDController,
              decoration: const InputDecoration(
                labelText: 'Option D',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Correct answer',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    value: 0,
                    groupValue: _correctOptionIndex,
                    title: const Text('A'),
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value ?? 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    value: 1,
                    groupValue: _correctOptionIndex,
                    title: const Text('B'),
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    value: 2,
                    groupValue: _correctOptionIndex,
                    title: const Text('C'),
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value ?? 2;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    value: 3,
                    groupValue: _correctOptionIndex,
                    title: const Text('D'),
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value ?? 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.isNotEmpty &&
                _optionAController.text.isNotEmpty &&
                _optionBController.text.isNotEmpty &&
                _optionCController.text.isNotEmpty &&
                _optionDController.text.isNotEmpty) {
              final options = [
                _optionAController.text,
                _optionBController.text,
                _optionCController.text,
                _optionDController.text,
              ];
              final correctAnswer = options[_correctOptionIndex.clamp(0, 3)];

              widget.onAdd(
                QuestionItem(
                  questionText: _questionController.text,
                  points: double.tryParse(_pointsController.text) ?? 1,
                  level: _selectedLevel,
                  options: options,
                  correctAnswer: correctAnswer,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

