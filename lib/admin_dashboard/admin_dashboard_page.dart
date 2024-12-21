// lib/admin_dashboard/admin_restaurant_list_page.dart

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_form_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_delete_page.dart';
import 'package:denpasar_food_mobile/models/restaurant.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';
import '../widgets/left_drawer.dart'; // Import left_drawer.dart
import 'admin_user_list_page.dart'; // Import admin_user_list_page.dart
import '../restaurant_list/restaurant_list.dart'; // Import RestaurantListPage

class AdminRestaurantListPage extends StatefulWidget {
  const AdminRestaurantListPage({super.key});

  @override
  _AdminRestaurantListPageState createState() =>
      _AdminRestaurantListPageState();
}

class _AdminRestaurantListPageState extends State<AdminRestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Restaurant> _restaurants = [];
  List<int> _selectedRestaurantIds = [];
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final fetchedRestaurants = await RestaurantListPage.fetchRestaurantsStatic(
          context); // Use the static helper function
      await _localStorageService.saveRestaurants(fetchedRestaurants);
      _filterRestaurants();
    } catch (e) {
      print('Error fetching and saving restaurants: $e');
      // Load from local storage if fetching fails
      _loadLocalRestaurants();
    }
  }

  Future<void> _loadLocalRestaurants() async {
    final localRestaurants = await _localStorageService.getRestaurants();
    setState(() {
      _restaurants = localRestaurants;
    });
  }

  void _filterRestaurants() async {
    final localRestaurants = await _localStorageService.getRestaurants();
    setState(() {
      _restaurants = localRestaurants.where((restaurant) {
        return restaurant.name!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (restaurant.address != null &&
                restaurant.address!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterRestaurants();
  }

  void _toggleRestaurantSelection(int restaurantId) {
    setState(() {
      if (_selectedRestaurantIds.contains(restaurantId)) {
        _selectedRestaurantIds.remove(restaurantId);
      } else {
        _selectedRestaurantIds.add(restaurantId);
      }
    });
  }

  void _selectAllRestaurants(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedRestaurantIds = _restaurants.map((r) => r.id!).toList();
      } else {
        _selectedRestaurantIds.clear();
      }
    });
  }

  Future<void> _deleteSelectedRestaurants() async {
    if (_selectedRestaurantIds.isEmpty) return;

    List<Restaurant> updatedRestaurants = _restaurants
        .where((restaurant) => !_selectedRestaurantIds.contains(restaurant.id))
        .toList();

    await _localStorageService.saveRestaurants(updatedRestaurants);
    setState(() {
      _restaurants = updatedRestaurants;
      _selectedRestaurantIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant List')),
      drawer: const LeftDrawer(), // Use the imported LeftDrawer
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: Colors.yellow[500],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSidebarItem(
                    context,
                    'Users',
                    Icons.person,
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminUserListPage()), // Use the imported class
                      );
                    },
                    isSelected:
                        ModalRoute.of(context)?.settings.name == '/admin/users',
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarItem(
                    context,
                    'Restaurants',
                    Icons.restaurant,
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminRestaurantListPage()), // Use the imported class
                      );
                    },
                    isSelected: ModalRoute.of(context)?.settings.name ==
                        '/admin/restaurants',
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Toolbar
                  Row(
                    children: [
                      // Batch Delete Button
                      ElevatedButton(
                        onPressed: _deleteSelectedRestaurants,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Selected'),
                      ),
                      const SizedBox(width: 16),
                      // Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search restaurants...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add Restaurant Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminRestaurantFormPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Restaurant'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Restaurant List Table
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Checkbox(
                              value: _selectedRestaurantIds.length ==
                                  _restaurants.length,
                              onChanged: _selectAllRestaurants,
                            ),
                          ),
                          const DataColumn(label: Text('Name')),
                          const DataColumn(label: Text('Cuisine')),
                          const DataColumn(label: Text('Address')),
                          const DataColumn(label: Text('Phone')),
                          const DataColumn(label: Text('Actions')),
                        ],
                        rows: _restaurants.map((restaurant) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: _selectedRestaurantIds
                                      .contains(restaurant.id),
                                  onChanged: (bool? checked) {
                                    _toggleRestaurantSelection(restaurant.id!);
                                  },
                                ),
                              ),
                              DataCell(Text(restaurant.name ?? 'N/A')),
                              DataCell(Text(
                                  restaurant.cuisines?.join(", ") ?? 'N/A')),
                              DataCell(Text(restaurant.address ?? 'N/A')),
                              DataCell(Text(restaurant.phone ?? 'N/A')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminRestaurantFormPage(
                                                    restaurant: restaurant),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminRestaurantDeletePage(
                                                    restaurant: restaurant),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool isSelected = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[600] : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
