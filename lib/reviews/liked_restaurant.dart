import 'package:flutter/material.dart';

class LikedRestaurantsPage extends StatelessWidget {
  const LikedRestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for liked restaurants
    final List<Map<String, String>> likedRestaurants = [
      {'name': 'BB52 Burgers Uluwatu', 'cuisine': 'American, Fast Food'},
      {'name': 'Made’s Warung', 'cuisine': 'Indonesian'},
      {'name': 'La Brisa Bali', 'cuisine': 'Seafood, International'},
      {'name': 'Nook', 'cuisine': 'Asian, Vegetarian'},
      {'name': 'The Lawn Canggu', 'cuisine': 'Western, Beachside'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF854158), 
        title: Text(
          'Your liked restaurants',
          style: TextStyle(
            color: const Color(0xFFF6D078), 
            fontSize: 21,
            fontWeight: FontWeight.bold,
            
          ),
          
        ),
        iconTheme: IconThemeData(
        color: const Color(0xFFF6D078),
         ), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Liked Restaurants',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: likedRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = likedRestaurants[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFF5F5F5),
                    child: ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        restaurant['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        restaurant['cuisine']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
