import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/map/map_page.dart';
import 'package:denpasar_food_mobile/admin_dashboard/admin_restaurant_list_page.dart'; // Import the admin page
import 'package:denpasar_food_mobile/restaurant_list/restaurant_list.dart'; // Import the RestaurantListPage
import 'package:denpasar_food_mobile/reviews/liked_restaurant.dart'; // Import the LikedRestaurantsPage
import 'package:denpasar_food_mobile/authentication/login.dart'; // Import the LoginPage
import 'package:denpasar_food_mobile/authentication/register.dart'; // Import the RegisterPage

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image:DecorationImage(image: 
              AssetImage('../../assets/drawer_background.png'), 
              fit: BoxFit.cover),
              color: Color(0x80854158), // Light purple color
            ),
            
            child:
            Padding(  
            padding: const EdgeInsets.only(top: 15),
              child:   
              
          Text(
              "Restaurants in Denpasar",
              textAlign: TextAlign.center,
              style: TextStyle(
                
                
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color:  Color(0xFFF6D078),
                shadows: [
                         Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(128, 0, 0, 0),
                           ),
                        ],
              ),
            ),
              ),
            ),
            
          
          ListTile(
            leading: const Icon(Icons.login, color: Colors.black),
            title: const Text("Login"),
            onTap: () {
              // Navigate to LoginPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration, color: Colors.black),
            title: const Text("Register"),
            onTap: () {
              // Navigate to RegisterPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text("Restaurant List"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.black),
            title: const Text("Map"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.black),
            title: const Text("Liked Restaurants"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LikedRestaurantsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person,
                color: Colors.black), // User icon for Admin Dashboard
            title: const Text("Admin Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminRestaurantListPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
