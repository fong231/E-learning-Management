import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/forum_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/forum_provider.dart';

class StudentTopicChatScreen extends StatefulWidget {
  const StudentTopicChatScreen({
    super.key,
    required this.topic,
  });

  final TopicModel topic;

  @override
  State<StudentTopicChatScreen> createState() => _StudentTopicChatScreenState();
}

class _StudentTopicChatScreenState extends State<StudentTopicChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChats();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    // todo call ForumProvider.loadTopicChats(topic.id)
    await forumProvider.loadTopicChats(widget.topic.id);

    setState(() {
      _isLoading = false;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    final userId = authProvider.userId;
    final role = authProvider.userRole;
    final userName = authProvider.currentUser?.fullname;
    if (userId == null || role == null) return;

    final chatData = {
      'topic_id': widget.topic.id,
      'user_id': userId,
      'user_role': role,
      'user_name': userName,
      'message': text,
    };

    // todo call ForumProvider.addTopicChat(chatData)
    await forumProvider.addTopicChat(chatData);

    _messageController.clear();
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ForumProvider>(
              builder: (context, forumProvider, child) {
                final chats = forumProvider.chats;

                if (_isLoading && chats.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final currentUserId = authProvider.userId;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final bool isMe =
                        currentUserId != null && chat.userId == currentUserId;

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
                              chat.message,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat.userName ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
