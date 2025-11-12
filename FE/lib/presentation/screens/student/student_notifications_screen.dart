import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StudentNotificationsScreen extends StatelessWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark as Read'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          final isRead = index % 3 == 0;
          return Container(
            color: isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getNotificationColor(index).withOpacity(0.1),
                child: Icon(_getNotificationIcon(index), color: _getNotificationColor(index)),
              ),
              title: Text(_getNotificationTitle(index)),
              subtitle: Text('${index + 1} giờ trước'),
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
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.announcement;
      case 1:
        return Icons.assignment;
      case 2:
        return Icons.message;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.orange;
      case 1:
        return AppTheme.accentColor;
      case 2:
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getNotificationTitle(int index) {
    switch (index % 4) {
      case 0:
        return 'Thông báo mới từ giảng viên';
      case 1:
        return 'Assignment mới được giao';
      case 2:
        return 'New Message';
      default:
        return 'Cập nhật hệ thống';
    }
  }
}

