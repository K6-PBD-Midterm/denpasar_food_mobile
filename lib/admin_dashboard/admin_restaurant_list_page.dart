// lib/admin_dashboard/admin_restaurant_list_page.dart

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_form_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_delete_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_user_list_page.dart';
import 'package:denpasar_food_mobile/models/restaurant.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';
import '../widgets/left_drawer.dart';
import '../restaurant_list/restaurant_list.dart';

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

  // Fixed widths for stable layout
  final double _checkboxColumnWidth = 40.0;
  final double _nameColumnWidth = 200.0;
  final double _actionsColumnWidth = 150.0;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final fetchedRestaurants =
          await RestaurantPage.fetchRestaurantsStatic(context);
      await _localStorageService.saveRestaurants(fetchedRestaurants);
      _filterRestaurants();
    } catch (e) {
      print('Error fetching and saving restaurants: $e');
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
        return (restaurant.name ?? '')
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
      drawer: const LeftDrawer(),
      body: Row(
        children: [
          // Sidebar with icons only
          Container(
            width: 80,
            color: Colors.yellow[500],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminUserListPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  IconButton(
                    icon: const Icon(Icons.restaurant, color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminRestaurantListPage()),
                      );
                    },
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
                            MaterialPageRoute(builder: (context) => const AdminRestaurantFormPage()),
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
                  // Data Table with the Actions column before Address column
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double totalWidth = constraints.maxWidth;
                        // Fixed width: checkbox + name + actions
                        final double fixedWidth = _checkboxColumnWidth + _nameColumnWidth + _actionsColumnWidth;
                        double addressColumnWidth = totalWidth - fixedWidth;
                        // If not enough room, clamp address column
                        if (addressColumnWidth < 20) {
                          addressColumnWidth = 20;
                        }

                        return DataTable(
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: _checkboxColumnWidth,
                                child: Checkbox(
                                  value: _selectedRestaurantIds.length == _restaurants.length && _restaurants.isNotEmpty,
                                  onChanged: _selectAllRestaurants,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: _nameColumnWidth,
                                child: const Text('Name'),
                              ),
                            ),
                            // Actions column before Address
                            DataColumn(
                              label: SizedBox(
                                width: _actionsColumnWidth,
                                child: const Text('Actions'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: addressColumnWidth,
                                child: const Text('Address'),
                              ),
                            ),
                          ],
                          rows: _restaurants.map((restaurant) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: _checkboxColumnWidth,
                                    child: Checkbox(
                                      value: _selectedRestaurantIds.contains(restaurant.id),
                                      onChanged: (bool? checked) {
                                        _toggleRestaurantSelection(restaurant.id!);
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: _nameColumnWidth,
                                    child: Text(
                                      restaurant.name ?? 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: _actionsColumnWidth,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AdminRestaurantFormPage(restaurant: restaurant),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AdminRestaurantDeletePage(restaurant: restaurant),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: addressColumnWidth,
                                    child: Text(
                                      restaurant.address ?? 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
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
}
