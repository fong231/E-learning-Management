import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/forum_model.dart';
import '../../../data/services/api_service.dart';
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
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChatsAndFiles();
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

  Future<void> _loadChatsAndFiles() async {
    setState(() {
      _isLoading = true;
    });

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.loadTopicChats(widget.topic.id);
    await forumProvider.loadTopicFiles(widget.topic.id);

    setState(() {
      _isLoading = false;
    });

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

    final topicChannel = 'topic:${widget.topic.id}';
    channel.sink.add(jsonEncode({
      'action': 'subscribe',
      'receiver_id': topicChannel,
    }));

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

        if (data is Map && data['type'] == 'new_topic_chat') {
          final dynamic chat = data['chat'];
          if (chat is! Map) return;

          final dynamic topicId = chat['topic_id'] ?? chat['topicId'];
          if (topicId is int && topicId == widget.topic.id) {
            if (mounted) {
              await _loadChatsAndFiles();
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

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) {
      return;
    }

    final path = result.files.single.path!;
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.uploadTopicFile(widget.topic.id, path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachment uploaded')),
    );
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

    if (_channel != null) {
      try {
        final wsPayload = {
          'action': 'message',
          'channel_type': 'topic',
          'receiver_id': widget.topic.id,
          'content': text,
        };
        _channel!.sink.add(jsonEncode(wsPayload));
      } catch (_) {
        // If WebSocket send fails, fall back to REST below
      }

      _messageController.clear();
      await _loadChatsAndFiles();
      return;
    }

    final chatData = {
      'topic_id': widget.topic.id,
      'user_id': userId,
      'user_role': role,
      'user_name': userName,
      'message': text,
    };

    await forumProvider.addTopicChat(chatData);

    _messageController.clear();
    await _loadChatsAndFiles();
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
                final files = forumProvider.topicFiles;

                if (_isLoading && chats.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chats.isEmpty && files.isEmpty) {
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

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (files.isNotEmpty) ...[
                      Text(
                        'Attachments',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final file in files)
                        ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text(
                            file.fileUrl.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            final url =
                                Uri.parse('${AppConstants.baseUrl}/uploads/${file.fileUrl}');
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open file')),
                                );
                              }
                            }
                          },
                        ),
                      const Divider(),
                      const SizedBox(height: 8),
                    ],
                    for (final chat in chats)
                      Builder(
                        builder: (context) {
                          final bool isMe =
                              currentUserId != null && chat.userId == currentUserId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
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
                                      chat.message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
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
                            ),
                          );
                        },
                      ),
                  ],
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
                    icon: const Icon(Icons.attach_file),
                    color: AppTheme.primaryColor,
                    onPressed: _pickAndUploadFile,
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
