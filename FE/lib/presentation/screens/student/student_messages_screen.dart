import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/message_provider.dart';
import 'student_chat_screen.dart';

class StudentMessagesScreen extends StatefulWidget {
  const StudentMessagesScreen({super.key});

  @override
  State<StudentMessagesScreen> createState() => _StudentMessagesScreenState();
}

class _StudentMessagesScreenState extends State<StudentMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    final userId = authProvider.userId;
    if (userId == null) return;

    await messageProvider.loadUserMessages(userId);
    await messageProvider.refreshUnreadCounts(userId: userId, studentId: userId);

    // Preload all courses the student participates in for instructor list
    await courseProvider.loadStudentCoursesAll(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final currentUserId = authProvider.userId;

          if (messageProvider.isLoading && messageProvider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<MessageModel> allMessages = messageProvider.messages;

          if (allMessages.isEmpty || currentUserId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          // Build latest message per conversation partner
          final Map<int, MessageModel> latestByPartner = {};
          for (final m in allMessages) {
            final bool isSender = m.senderId == currentUserId;
            final int partnerId = isSender ? m.receiverId : m.senderId;
            final existing = latestByPartner[partnerId];
            if (existing == null || m.sentAt.isAfter(existing.sentAt)) {
              latestByPartner[partnerId] = m;
            }
          }

          // Ensure all instructors from enrolled courses appear at least once
          final courseProvider =
              Provider.of<CourseProvider>(context, listen: false);
          final List<CourseModel> courses = courseProvider.courses;
          final Map<int, String> instructors = {};
          for (final c in courses) {
            if (c.instructorId != 0) {
              instructors[c.instructorId] = c.instructorName ?? 'Instructor';
            }
          }

          for (final entry in instructors.entries) {
            final int instructorId = entry.key;
            final String instructorName = entry.value;
            if (!latestByPartner.containsKey(instructorId)) {
              latestByPartner[instructorId] = MessageModel(
                id: 0,
                senderId: currentUserId,
                senderName: null,
                senderRole: AppConstants.roleStudent,
                receiverId: instructorId,
                receiverName: instructorName,
                receiverRole: AppConstants.roleInstructor,
                content: 'Start a conversation',
                isRead: true,
                sentAt: DateTime.now(),
              );
            }
          }

          final List<MessageModel> conversations = latestByPartner.values.toList()
            ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

          if (conversations.isEmpty) {
            return Center(
              child: Text(
                'No messages yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMessages,
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final message = conversations[index];
                final bool isSender = message.senderId == currentUserId;
                final int otherUserId =
                    isSender ? message.receiverId : message.senderId;
                final String otherName = isSender
                    ? (message.receiverName ?? 'Instructor')
                    : (message.senderName ?? 'Instructor');
                final String otherRole =
                    isSender ? message.receiverRole : message.senderRole;
                final bool isUnread =
                    !message.isRead && message.receiverId == currentUserId;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      otherName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  title: Text(otherName),
                  subtitle: Text(
                    message.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (isUnread) {
                      messageProvider.markMessageAsRead(message.id);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentChatScreen(
                          otherUserId: otherUserId,
                          otherUserName: otherName,
                          otherUserRole: otherRole,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New message screen is under development'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
