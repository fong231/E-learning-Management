import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    final userId = authProvider.userId;
    if (userId == null) return;

    await messageProvider.loadNotifications(userId);
    await messageProvider.refreshUnreadCounts(userId: userId, studentId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final messageProvider = Provider.of<MessageProvider>(context, listen: false);
              for (final n in messageProvider.notifications.where((n) => !n.isRead)) {
                await messageProvider.markNotificationAsRead(n.id);
              }
            },
            child: const Text('Mark as Read'),
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading && messageProvider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: messageProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = messageProvider.notifications[index];
                final isRead = notification.isRead;
                final icon = _getNotificationIcon(notification.type);
                final color = _getNotificationColor(notification.type);

                return Container(
                  color: isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(notification.title),
                    subtitle: Text(notification.content),
                    trailing: !isRead
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      if (!isRead) {
                        messageProvider.markNotificationAsRead(notification.id);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'announcement':
        return Icons.announcement;
      case 'deadline':
        return Icons.assignment;
      case 'message':
        return Icons.message;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'announcement':
        return Colors.orange;
      case 'deadline':
        return AppTheme.accentColor;
      case 'message':
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }
}
