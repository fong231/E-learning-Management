import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_service.dart';
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
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadConversation();
      await _connectWebSocket();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

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

  Future<void> _connectWebSocket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId == null) return;

    final apiService = ApiService();
    final token = await apiService.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final base = AppConstants.baseUrl;
    final wsBase = base.startsWith('https')
        ? base.replaceFirst('https', 'wss')
        : base.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsBase/ws/$token');

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    channel.sink.add(
      jsonEncode({'action': 'subscribe', 'receiver_id': userId}),
    );

    _wsSubscription = channel.stream.listen(
      (event) async {
        dynamic data = event;
        if (event is String) {
          try {
            data = jsonDecode(event);
          } catch (_) {
            return;
          }
        }

        if (data is Map && data['type'] == 'new_message') {
          final dynamic message = data['message'];
          if (message is! Map) return;

          final dynamic senderId = message['sender_id'] ?? message['senderId'];
          final dynamic receiverId =
              message['receiver_id'] ?? message['receiverId'];

          if (senderId is int && receiverId is int) {
            final int myId = userId;
            final int otherId = widget.otherUserId;

            if ((senderId == myId && receiverId == otherId) ||
                (senderId == otherId && receiverId == myId)) {
              if (mounted) {
                await _loadConversation();
              }
            }
          }
        }
      },
      onError: (error) {
        // Ignore WebSocket errors for now
      },
      onDone: () {
        _channel = null;
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    final userId = authProvider.userId;
    final role = authProvider.userRole;
    if (userId == null || role == null) return;

    final isStudent = role == AppConstants.roleStudent;

    if (_channel != null) {
      try {
        final wsPayload = {
          'action': 'message',
          'channel_type': 'dm',
          'receiver_id': widget.otherUserId,
          'content': text,
        };
        _channel!.sink.add(jsonEncode(wsPayload));
      } catch (_) {
        // If WebSocket send fails, fall back to REST below
      }

      _messageController.clear();
      await _loadConversation();
      return;
    }

    final messageData = {
      'sender_id': userId,
      'receiver_id': widget.otherUserId,
      'content': text,
      'sender_role': role,
      'receiver_role': isStudent
          ? AppConstants.roleInstructor
          : AppConstants.roleStudent,
    };

    await messageProvider.sendMessage(messageData);
    _messageController.clear();

    await _loadConversation();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
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
                    final bool isMe =
                        currentUserId != null &&
                        message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
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
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isMe
                                          ? Colors.white70
                                          : AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
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
