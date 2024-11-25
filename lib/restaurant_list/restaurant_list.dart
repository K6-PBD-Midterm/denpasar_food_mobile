import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> { 
  Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    try {
      final response = await request.get('https://denpasar-food.vercel.app/json/');
      List<Restaurant> listRestaurant = [];

      // Ensure response is treated as List<dynamic>
      if (response is List) {
        for (var d in response) {
          if (d != null && d is Map<String, dynamic>) {
            listRestaurant.add(Restaurant.fromJson(d));
          }
        }
      }
      return listRestaurant;
    } catch (e) {
      // Print error for debugging
      print('Error fetching restaurants: $e');
      throw Exception('Failed to load restaurants');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants in Denpasar'),
      ),
      body: FutureBuilder(
        future: fetchRestaurants(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(
              child: Text(
                'No restaurants available.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data[index].name ?? 'No name',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(snapshot.data[index].description ?? 'No description'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(" ${snapshot.data[index].rating ?? 'N/A'}"),
                        const SizedBox(width: 20),
                        Text("Price: ${snapshot.data[index].priceRange ?? 'Not specified'}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Address: ${snapshot.data[index].address ?? 'No address'}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
