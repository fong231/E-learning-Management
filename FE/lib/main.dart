import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:source_code/presentation/providers/course_provider.dart';
import 'package:source_code/presentation/providers/instructor_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/providers/assignment_provider.dart';
import 'presentation/providers/instructor_student_provider.dart';
import 'presentation/providers/quiz_provider.dart';
import 'presentation/providers/message_provider.dart';
import 'presentation/providers/forum_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => InstructorProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => InstructorStudentProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
      ],
      child: MaterialApp(
        title: 'LMS - Learning Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
