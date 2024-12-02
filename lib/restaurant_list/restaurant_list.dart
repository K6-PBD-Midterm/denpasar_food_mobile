import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Add this import

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> { 
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<String> _selectedCuisines = [];
  List<String> _allCuisines = [];
  Key _dropdownKey = GlobalKey(); // Add this line at the top with other variables

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Set<String> _extractUniqueCuisines(List<Restaurant> restaurants) {
    Set<String> cuisines = {};
    for (var restaurant in restaurants) {
      if (restaurant.cuisines != null) {
        cuisines.addAll(restaurant.cuisines!);
      }
    }
    return cuisines;
  }

  Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    try {
      final response = await request.get('https://denpasar-food.vercel.app/json/');
      List<Restaurant> listRestaurant = [];

      if (response is List) {
        for (var d in response) {
          if (d != null && d is Map<String, dynamic>) {
            listRestaurant.add(Restaurant.fromJson(d));
          }
        }
      }

      // Update all cuisines list
      _allCuisines = _extractUniqueCuisines(listRestaurant).toList()..sort();

      // Filter restaurants based on search query and selected cuisines
      if (_searchQuery.isNotEmpty || _selectedCuisines.isNotEmpty) {
        listRestaurant = listRestaurant.where((restaurant) {
          bool matchesSearch = _searchQuery.isEmpty ||
              (restaurant.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (restaurant.description != null && 
                restaurant.description!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
              (restaurant.address != null && 
                restaurant.address!.toLowerCase().contains(_searchQuery.toLowerCase()));

          bool matchesCuisine = _selectedCuisines.isEmpty ||
              (restaurant.cuisines?.any((cuisine) => 
                _selectedCuisines.contains(cuisine)) ?? false);

          return matchesSearch && matchesCuisine;
        }).toList();
      }

      return listRestaurant;
    } catch (e) {
      // Print error for debugging
      print('Error fetching restaurants: $e');
      throw Exception('Failed to load restaurants');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        _selectedCuisines.add(cuisine);
      }
      _dropdownKey = GlobalKey();
    });
  }

  String? getTodayClosingTime(Restaurant restaurant) {
    if (restaurant.openHours == null) return null;
    
    final now = DateTime.now();
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayKey = days[now.weekday - 1];
    
    List<Fri>? todayHours;
    switch (todayKey) {
      case 'mon': todayHours = restaurant.openHours?.mon; break;
      case 'tue': todayHours = restaurant.openHours?.tue; break;
      case 'wed': todayHours = restaurant.openHours?.wed; break;
      case 'thu': todayHours = restaurant.openHours?.thu; break;
      case 'fri': todayHours = restaurant.openHours?.fri; break;
      case 'sat': todayHours = restaurant.openHours?.sat; break;
      case 'sun': todayHours = restaurant.openHours?.sun; break;
    }
    
    final closeTime = todayHours?.firstOrNull?.close;
    if (closeTime == null) return null;
        final timeParts = closeTime.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return closeTime;
  }

  String? getTodayOpeningTime(Restaurant restaurant) {
    if (restaurant.openHours == null) return null;
    
    final now = DateTime.now();
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayKey = days[now.weekday - 1];
    
    List<Fri>? todayHours;
    switch (todayKey) {
      case 'mon': todayHours = restaurant.openHours?.mon; break;
      case 'tue': todayHours = restaurant.openHours?.tue; break;
      case 'wed': todayHours = restaurant.openHours?.wed; break;
      case 'thu': todayHours = restaurant.openHours?.thu; break;
      case 'fri': todayHours = restaurant.openHours?.fri; break;
      case 'sat': todayHours = restaurant.openHours?.sat; break;
      case 'sun': todayHours = restaurant.openHours?.sun; break;
    }
    
    final openTime = todayHours?.firstOrNull?.open;
    if (openTime == null) return null;
    
    final timeParts = openTime.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return openTime;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants in Denpasar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<String>(
                    key: _dropdownKey, // Add key here
                    isExpanded: true,
                    hint: const Text('Filter by cuisine'),
                    value: null,
                    menuMaxHeight: 350, // Add maximum height
                    dropdownColor: Theme.of(context).cardColor, // Match theme
                    items: _allCuisines.map((String cuisine) {
                      final isSelected = _selectedCuisines.contains(cuisine);
                      return DropdownMenuItem<String>(
                        value: cuisine,
                        enabled: false,
                        child: InkWell(
                          onTap: () => _toggleCuisine(cuisine),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Transform.scale(
                                  scale: 1.1,
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: Theme.of(context).primaryColor,
                                    checkColor: Colors.white,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (bool? checked) => _toggleCuisine(cuisine),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cuisine,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
                if (_selectedCuisines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8, // Add vertical spacing between rows
                      children: _selectedCuisines.map((cuisine) => Chip(
                        label: Text(cuisine),
                        onDeleted: () {
                          setState(() {
                            _selectedCuisines.remove(cuisine);
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: Image.network(
                            snapshot.data[index].imageUrl ?? 'https://via.placeholder.com/150',
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                              const SizedBox(height: 8),
                              Text(
                                snapshot.data[index].cuisines?.join(", ") ?? 'Cuisine not specified',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: snapshot.data[index].isOpen == true ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    snapshot.data[index].isOpen == true
                                        ? "Open · Closes at ${getTodayClosingTime(snapshot.data[index]) ?? 'N/A'}"
                                        : "Closed · Opens at ${getTodayOpeningTime(snapshot.data[index]) ?? 'N/A'}",
                                    style: TextStyle(
                                      color: snapshot.data[index].isOpen == true ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  Text(" ${snapshot.data[index].rating ?? 'N/A'}"),
                                  const SizedBox(width: 20),
                                  Text("Price: ${snapshot.data[index].priceRange ?? 'Not specified'}"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Address: ${snapshot.data[index].address ?? 'No address'}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
