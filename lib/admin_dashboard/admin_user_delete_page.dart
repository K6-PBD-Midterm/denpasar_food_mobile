// lib/admin_dashboard/admin_user_delete_page.dart

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_user_list_page.dart';
import 'package:denpasar_food_mobile/models/local_user.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';

class AdminUserDeletePage extends StatelessWidget {
  final LocalUser user;
  const AdminUserDeletePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete "${user.username}"?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final localStorageService = LocalStorageService();
                    List<LocalUser> existingUsers =
                        await localStorageService.getUsers();
                    existingUsers.removeWhere((u) => u.id == user.id);
                    await localStorageService.saveUsers(existingUsers);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminUserListPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yes, Delete'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
