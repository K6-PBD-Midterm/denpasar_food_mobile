import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/screens/map_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_list_page.dart'; // Import the admin page
import 'package:denpasar_food_mobile/restaurant_list/restaurant_list.dart'; // Import the RestaurantPage

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              "Restaurants in Denpasar",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.login, color: Colors.black),
            title: const Text("Login"),
            onTap: () {
              // Add your login navigation or logic here
            },
          ),
          ListTile(
            leading: Icon(Icons.app_registration, color: Colors.black),
            title: const Text("Register"),
            onTap: () {
              // Add your register navigation or logic here
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: const Text("Restaurant List"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.map, color: Colors.black),
            title: const Text("Map"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark, color: Colors.black),
            title: const Text("Liked Restaurants"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text("Admin Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminRestaurantListPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
