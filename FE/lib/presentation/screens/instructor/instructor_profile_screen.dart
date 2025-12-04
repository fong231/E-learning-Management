import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/change_password_screen.dart';
import '../auth/edit_profile_screen.dart';
import '../auth/login_screen.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  String? getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return null;
    }

    if (avatarPath.startsWith('https://ui-avatars.com')) {
      return avatarPath;
    }

    return "${AppConstants.baseUrl}/uploads/$avatarPath";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            child: Column(
              children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.avatar != null
                        ? NetworkImage(getAvatarUrl(user?.avatar) ?? '')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullname ?? 'Instructor',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () {},
            ),
            const Divider(),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              textColor: AppTheme.errorColor,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
