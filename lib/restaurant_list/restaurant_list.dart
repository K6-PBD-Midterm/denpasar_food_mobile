import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/left_drawer.dart';
import '../reviews/review_page.dart';
import '../reviews/view_reviews.dart';
import '../map/map_page.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();

  //////////////////////// bonbon: Static helper function to fetch restaurants ////////////////////////
  static Future<List<Restaurant>> fetchRestaurantsStatic(
      BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final RestaurantListPageState =
        _RestaurantListPageState(); // Create an instance of _RestaurantListPageState
    return await RestaurantListPageState.fetchRestaurants(request);
  }
  //////////////////////// bonbon: Static helper function to fetch restaurants ////////////////////////
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  final List<String> _selectedCuisines = [];
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
        backgroundColor: const Color(0xFF854158), 
        title: Text(
          'Restaurants in Denpasar',
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
      drawer: const LeftDrawer(),

      body: 
      
      Column(
        children: [
          ClipRRect(
             borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
            child:
            Image.asset('../../assets/background_list.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 100,),),
          
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 8.0), 
            child: Column(
              children: [
                
               TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0x80F6D078), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0), 
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0), 
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color:  Color(0x80F6D078),
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
                                    checkColor:  Color(0x80F6D078),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.start,
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
                                 Padding( 
                                    padding: const EdgeInsets.only(top: 40),
                                    child:
                                  Container(
                                    width: 120,
                                    height: 120,
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
                                 ),                             
                                ],
                              ),

                              // Heart Icon
                              Positioned(
                                top: -10,
                                right: -10,
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
                       
                          // Add Review and View Review Buttons and location map
                         Row(
                          //mainAxisAlignment: MainAxisAlignment.center, // Centre les enfants horizontalement
                            children: [
                              //view on map
                             const SizedBox(width: 12),
                                   FloatingActionButton(
                                    onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapPage(searchQuery: snapshot.data[index].name, initialLatitude: snapshot.data[index].latitude,initialLongitude: snapshot.data[index].longitude),
                                    ),
                                  );
                                },
                                    backgroundColor: const Color.fromARGB(255, 194, 180, 146), 
                                    elevation: 10, 
                                    child: Icon(Icons.location_pin, color: const Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                
                              const SizedBox(width: 32),
                              Column (
                                children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ViewReviewsPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6D078),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), 
                                ),
                                ),
                                icon: const Icon(Icons.visibility,size: 20.0,color: Colors.black,),
                                label: const Text('View reviews',style: TextStyle(fontSize: 14.0,color: Colors.black),),
                              ),
                              const SizedBox(height: 5),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                           ReviewPage(restaurantId: snapshot.data[index].id, imageUrl: snapshot.data[index].imageUrl),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6D078),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), 
                                ),
                                ),
                                icon: const Icon(Icons.add,size: 20.0,color: Colors.black,),
                                label: const Text('Add a review',style: TextStyle(fontSize: 14.0,color: Colors.black),),
                              ),
                                ],
                              )
                              
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
