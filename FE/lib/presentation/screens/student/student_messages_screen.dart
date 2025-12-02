import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';

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

    final userId = authProvider.userId;
    if (userId == null) return;

    await messageProvider.loadUserMessages(userId);
    await messageProvider.refreshUnreadCounts(userId: userId, studentId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading && messageProvider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.messages.isEmpty) {
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
              itemCount: messageProvider.messages.length,
              itemBuilder: (context, index) {
                final message = messageProvider.messages[index];
                final isUnread = !message.isRead;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      (message.senderName ?? 'GV').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  title: Text(message.senderName ?? 'Instructor'),
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
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new message / choose instructor screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
