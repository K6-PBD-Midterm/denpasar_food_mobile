import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/screens/map_page.dart';

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
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.app_registration, color: Colors.black),
            title: const Text("Register"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: const Text("Restaurant List"),
            onTap: () {},
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
        ],
      ),
    );
  }
}
