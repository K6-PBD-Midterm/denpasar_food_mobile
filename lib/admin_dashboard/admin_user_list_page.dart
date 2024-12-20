import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_user_form_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_user_delete_page.dart';
import 'package:denpasar_food_mobile/models/local_user.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';
import '../widgets/left_drawer.dart';
import 'admin_restaurant_list_page.dart' as admin_restaurant;

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  _AdminUserListPageState createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<LocalUser> _users = [];
  List<int> _selectedUserIds = [];
  final LocalStorageService _localStorageService = LocalStorageService();

  // Fixed column widths
  final double _checkboxColumnWidth = 40.0;
  final double _usernameColumnWidth = 200.0;
  final double _actionsColumnWidth = 150.0;
  final double _emailColumnWidth = 300.0;
  final double _activeColumnWidth = 70.0;
  final double _adminColumnWidth = 70.0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final localUsers = await _localStorageService.getUsers();
    setState(() {
      _users = localUsers;
    });
  }

  void _filterUsers() async {
    final localUsers = await _localStorageService.getUsers();
    setState(() {
      _users = localUsers.where((user) {
        return user.username
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterUsers();
  }

  void _toggleUserSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _selectAllUsers(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedUserIds = _users.map((u) => u.id).toList();
      } else {
        _selectedUserIds.clear();
      }
    });
  }

  Future<void> _deleteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) return;

    List<LocalUser> updatedUsers =
        _users.where((user) => !_selectedUserIds.contains(user.id)).toList();

    await _localStorageService.saveUsers(updatedUsers);
    setState(() {
      _users = updatedUsers;
      _selectedUserIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      drawer: const LeftDrawer(),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Colors.yellow[500],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.person, color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminUserListPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  IconButton(
                    icon: const Icon(Icons.restaurant,
                        color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const admin_restaurant
                                .AdminRestaurantListPage()),
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
                      ElevatedButton(
                        onPressed: _deleteSelectedUsers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Selected'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminUserFormPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Inside the Expanded widget that contains your DataTable:

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align contents to start (left)
                      children: [
                        // ... your toolbar row, etc.

                        const SizedBox(height: 16),

                        // Wrap the table in Align to force it to the top-left
                        Align(
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: _checkboxColumnWidth,
                                    child: Checkbox(
                                      value: _selectedUserIds.length ==
                                              _users.length &&
                                          _users.isNotEmpty,
                                      onChanged: _selectAllUsers,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: _usernameColumnWidth,
                                    child: const Text('Username'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: _actionsColumnWidth,
                                    child: const Text('Actions'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: _emailColumnWidth,
                                    child: const Text('Email'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: _activeColumnWidth,
                                    child: const Text('Active'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: _adminColumnWidth,
                                    child: const Text('Admin'),
                                  ),
                                ),
                              ],
                              rows: _users.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: _checkboxColumnWidth,
                                        child: Checkbox(
                                          value: _selectedUserIds
                                              .contains(user.id),
                                          onChanged: (bool? checked) {
                                            _toggleUserSelection(user.id);
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: _usernameColumnWidth,
                                        child: Text(
                                          user.username,
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
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdminUserFormPage(
                                                            user: user),
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
                                                        AdminUserDeletePage(
                                                            user: user),
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
                                        width: _emailColumnWidth,
                                        child: Text(
                                          user.email,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: _activeColumnWidth,
                                        child: Text(
                                          user.isActive ? 'Yes' : 'No',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: _adminColumnWidth,
                                        child: Text(
                                          user.isSuperuser ? 'Yes' : 'No',
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
