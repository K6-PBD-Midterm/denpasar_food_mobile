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
            title: const Text("Login"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Register"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            title: const Text("Restaurant List"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Map"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
