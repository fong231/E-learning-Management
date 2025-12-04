import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
  });

  final int otherUserId;
  final String otherUserName;
  final String otherUserRole;

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    final userId = authProvider.userId;
    if (userId == null) return;

    // todo call MessageProvider.loadConversation(userId, otherUserId)
    await messageProvider.loadConversation(userId, widget.otherUserId);

    // mark all incoming messages as read
    for (final m in messageProvider.conversation) {
      if (!m.isRead && m.receiverId == userId) {
        await messageProvider.markMessageAsRead(m.id);
      }
    }

    // auto-scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    final userId = authProvider.userId;
    final role = authProvider.userRole;
    if (userId == null || role == null) return;

    final isStudent = role == AppConstants.roleStudent;

    final messageData = {
      'sender_id': userId,
      'receiver_id': widget.otherUserId,
      'content': text,
      'sender_role': role,
      'receiver_role': isStudent
          ? AppConstants.roleInstructor
          : AppConstants.roleStudent,
    };

    // todo call MessageProvider.sendMessage(messageData)
    await messageProvider.sendMessage(messageData);
    _messageController.clear();

    await _loadConversation();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final messages = messageProvider.conversation;

                if (messageProvider.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = currentUserId != null &&
                        message.senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppTheme.primaryColor.withOpacity(0.9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isMe
                                            ? Colors.white70
                                            : AppTheme.textSecondaryColor,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: AppTheme.primaryColor,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
