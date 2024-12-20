import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/left_drawer.dart';
import '../reviews/review_page.dart';
import '../reviews/view_reviews.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();

  //////////////////////// bonbon: Static helper function to fetch restaurants ////////////////////////
  static Future<List<Restaurant>> fetchRestaurantsStatic(
      BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final restaurantPageState =
        _RestaurantPageState(); // Create an instance of _RestaurantPageState
    return await restaurantPageState.fetchRestaurants(request);
  }
  //////////////////////// bonbon: Static helper function to fetch restaurants ////////////////////////
}

class _RestaurantPageState extends State<RestaurantPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<String> _selectedCuisines = [];
  List<String> _allCuisines = [];
  Key _dropdownKey = GlobalKey();

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
      final response =
          await request.get('https://denpasar-food.vercel.app/json/');
      List<Restaurant> listRestaurant = [];

      if (response is List) {
        for (var d in response) {
          if (d != null && d is Map<String, dynamic>) {
            listRestaurant.add(Restaurant.fromJson(d));
          }
        }
      }

      _allCuisines = _extractUniqueCuisines(listRestaurant).toList()..sort();

      if (_searchQuery.isNotEmpty || _selectedCuisines.isNotEmpty) {
        listRestaurant = listRestaurant.where((restaurant) {
          bool matchesSearch = _searchQuery.isEmpty ||
              (restaurant.name
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (restaurant.description != null &&
                  restaurant.description!
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) ||
              (restaurant.address != null &&
                  restaurant.address!
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()));

          bool matchesCuisine = _selectedCuisines.isEmpty ||
              (restaurant.cuisines
                      ?.any((cuisine) => _selectedCuisines.contains(cuisine)) ??
                  false);

          return matchesSearch && matchesCuisine;
        }).toList();
      }

      return listRestaurant;
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants in Denpasar'),
      ),
      drawer: const LeftDrawer(),
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
                    key: _dropdownKey,
                    isExpanded: true,
                    hint: const Text('Filter by cuisine'),
                    value: null,
                    menuMaxHeight: 350,
                    dropdownColor: Theme.of(context).cardColor,
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
                                    checkColor: Color(0xFFD9D9D9),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (bool? checked) =>
                                        _toggleCuisine(cuisine),
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
                      runSpacing: 8,
                      children: _selectedCuisines
                          .map((cuisine) => Chip(
                                label: Text(cuisine),
                                onDeleted: () {
                                  setState(() {
                                    _selectedCuisines.remove(cuisine);
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                              ))
                          .toList(),
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
                  itemBuilder: (_, index) => 
                  Card(
                    margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                    color: const Color(0xFF854158),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Restaurant Name
                                        Text(
                                          snapshot.data[index].name ??
                                              'Restaurant Name',
                                          style: const TextStyle(
                                            fontSize: 20.0,
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
                                        const SizedBox(height: 10),

                                        // Cuisine
                                        snapshot.data[index].phone != null && 
                                        snapshot.data[index].phone!.isNotEmpty 
                                        ?
                                         Row(
                                          children: [
                                            const Icon(
                                              Icons.food_bank, // Icône d'épingle (vous pouvez choisir une autre icône si vous le souhaitez)
                                              color: Color(0xFFD9D9D9),
                                              size: 16.0,
                                            ),
                                            const SizedBox(width: 5.0), // Espacement entre l'icône et le texte
                                            Expanded(
                                              child: Text(
                                                 "${snapshot.data[index].cuisines?.join(', ') ?? 'No cuisines information available :('}",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Color(0xFFD9D9D9),
                                                  height : 1.2,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ],
                                        )
                                        : const SizedBox.shrink(),

                                        // Address
                                        /*Text(
                                          "Address: ${snapshot.data[index].address ?? 'N/A'}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),*/
                                        const SizedBox(height: 4),

                                        // Phone
                                        snapshot.data[index].phone != null && 
                                        snapshot.data[index].phone!.isNotEmpty 
                                        ? Row(
                                          children: [
                                            const Icon(
                                              Icons.phone, // Icône d'épingle (vous pouvez choisir une autre icône si vous le souhaitez)
                                              color: Color(0xFFD9D9D9),
                                              size: 16.0,
                                            ),
                                            const SizedBox(width: 4.0), // Espacement entre l'icône et le texte
                                            Expanded(
                                              child: Text(
                                                "${snapshot.data[index].phone ?? "no phone available :("}",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Color(0xFFD9D9D9),
                                  
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ],
                                        ) : const SizedBox.shrink(),
                                      const SizedBox(height: 4),
                                        // Website
                                         snapshot.data[index].website != null && 
                                        snapshot.data[index].website!.isNotEmpty 
                                        ? 
                                       Row(
                                          children: [
                                            const Icon(
                                              Icons.link, // Icône d'épingle (vous pouvez choisir une autre icône si vous le souhaitez)
                                              color: Color.fromARGB(255, 170, 168, 205),
                                              size: 16.0,
                                            ),
                                            const SizedBox(width: 4.0), // Espacement entre l'icône et le texte
                                            Expanded(
                                              child: Text(
                                                "${snapshot.data[index].website ?? "no website available :("}",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Color.fromARGB(255, 170, 168, 205),
                                                  
                                                ),
                                                
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                      ) : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Restaurant Image
                                 
                                    
                                    Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children :[
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: snapshot.data[index].imageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              snapshot.data[index].imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Center(
                                            child:
                                                Text('Picture not available'),
                                          ),
                                  ),
                                    ],
                                  ),
                                  
                                ],
                              ),

                              // Heart Icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "You have liked ${snapshot.data[index].name ?? 'this restaurant'}",
                                          style: const TextStyle(
                                              color: Color(0xFFD9D9D9)),
                                        ),
                                        backgroundColor:
                                            const Color(0xFF5C2A3C),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.favorite_border),
                                  color: const Color(0xFFF6D078),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Add Review and View Review Buttons
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewPage(
                                        restaurantId: snapshot.data[index].id,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6D078),
                                ),
                                icon: const Icon(Icons.add,color: Colors.black,),
                                label: const Text(
                                  'Add a review',
                                  style: TextStyle (color: Colors.black),
                                  ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ViewReviewsPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6D078),
                                ),
                                icon: const Icon(Icons.visibility,color: Colors.black,),
                                label: const Text('View reviews',style: TextStyle(color: Colors.black),),
                              ),
                            ],
                          ),
                        ],
                      ),
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
