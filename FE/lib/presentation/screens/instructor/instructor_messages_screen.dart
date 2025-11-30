import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InstructorMessagesScreen extends StatelessWidget {
  const InstructorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text('SV${index + 1}'),
            ),
            title: Text('Student ${index + 1}'),
            subtitle: Text('Latest message...'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${index + 1}h', style: Theme.of(context).textTheme.bodySmall),
                if (index % 3 == 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

