// lib/admin_dashboard/admin_restaurant_delete_page.dart

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_list_page.dart';
import 'package:denpasar_food_mobile/models/restaurant.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';

class AdminRestaurantDeletePage extends StatelessWidget {
  final Restaurant restaurant;
  const AdminRestaurantDeletePage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Restaurant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete "${restaurant.name}"?',
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
                    List<Restaurant> existingRestaurants = await localStorageService.getRestaurants();
                    existingRestaurants.removeWhere((r) => r.id == restaurant.id);
                    await localStorageService.saveRestaurants(existingRestaurants);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminRestaurantListPage()),
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