import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
 bool zoom = false;
  // filter restau
   final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  final List<String> _selectedCuisines = [];
   List<String> _allCuisines = [];
  Key _dropdownKey = GlobalKey(); 
  List<Restaurant> _restaurants = [];


  // flutter map
  final MapController _mapController = MapController();
  double _currentZoom = 12.0;
   List<Marker> _markers = [];
  OverlayEntry? _popupOverlayEntry;

 
Future<List<Restaurant>> _loadMarkers(CookieRequest request) async {
  print(zoom);
    if ( _restaurants.isNotEmpty) {

      zoom = false;
      return _restaurants;
    } 
    CookieRequest request = CookieRequest(); 
    
    List<Restaurant> restaurants = await fetchRestaurants(request);
   _allCuisines = _extractUniqueCuisines(restaurants).toList()..sort();
   setState ((){
    _restaurants = restaurants;
   });
    return restaurants;
  }
 

 
@override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // _zoom = false;
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
  void _zoomIn() {
    zoom = true;
    setState(() {
      _currentZoom += 1; 
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    zoom = true;
    setState(() {
      _currentZoom -= 1; 
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }
   Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    try {
      final response = await request.get('https://denpasar-food.vercel.app/json/');
      List<Restaurant> listRestaurant = [];
     
      if (response is List ) {
        for (var restaurant in response) {
          if (restaurant != null && restaurant is Map<String, dynamic>) {
            //decode json
            listRestaurant.add(Restaurant.fromJson(restaurant));
          }
        }
      }
      return listRestaurant;
    } catch (e) {
      print('Error when getting the restaurant list: $e');
      return [];
    } 
    }


    List<Restaurant>  filterRestaurants (List<Restaurant> restaurants) {
  
     if (_searchQuery.isNotEmpty || _selectedCuisines.isNotEmpty) {
        restaurants = restaurants.where((restaurant) {
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
    return restaurants;
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
  void _showPopup(BuildContext context, Restaurant restaurant) {
    _popupOverlayEntry?.remove(); 
    _popupOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 100,
        left: MediaQuery.of(context).size.width / 2 - 100,
       child: Material(
  color: Colors.transparent,
  child: Container(
    width: 200,
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
    
        Text(
          restaurant.name ?? 'Restaurant',
          style: const TextStyle(
            fontSize: 18.0, 
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Coins arrondis pour l'image
          child: Image.network(
            restaurant.imageUrl ?? "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAWlBMVEXv8fNod4f19vhkdIRcbX52g5KPmqX29/iYoq3l6OuCj5vd4eTr7fBfcIFaa33M0dbBx82SnKe7wchtfIt8iZejq7TU2N2Ik6CwuL/Gy9Gqsrqbpa/P1NmhqrNz0egRAAADBklEQVR4nO3c63KqMBRAYUiwwUvEete27/+ax1tVAqhwEtnprO+XM62Oyw2CGTFJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJe6Mb5vqL7jjsws/wgln/dddzBZZjocuxj2HaiWNg1JL/oO3GVBA9PUzvvdF80q7AgPQ/zot1DlOnThyFBIIYWvFtrMK3mFdj30aWzFFWZjr+/qE4mFXh+YwrehsDMK34bCzmIoVEad1nC6PbD8QpXMNwOdDvKi2xMUX2jm2h7/onU2WHcZo/RCld8WN3TWZR1CeKH6LK1tTGftE2UXqpmzPGXbLwnKLkzcT8X6s/UQRReqWWX9LWs9RNGF5qOysmFb74miC9XCDUzt6k8VJtXC9jsihW9Tu5Uuq/vhvlKokuGjc1bRhWZVLdw5MWq8mU6zfNL4wKILk/W0spW6dyvOZ61p4wKd7EIzcoZot+UQVVxeA62bEmUXJuPyIV8PnDsVtxXtpikKL1S7++1U6/IZzV1g8xSFFx4i9HWMdjksNZQCGxOlFyZq8jW1VmubpZV90PngUZ8ovvDYuNt//Wy/1ZPAhsQICo+rUMa4T70msP7tJorCun8vKofKhilGWlg7wfopxlnYMMHaKUZZ2DjBuinGWPgwsDLFCAufBLqJ8RU+DXQ21OgKXwgsTzG2wpcCj1O8nsJGVvjgMNE0xbgKX5zgeYqXxKgKX57geYrnDTWmwhYTvJtiRIUtA3/fbuIpbB14mWI0hR0Cz1OMpbBT4CkxiaOwY+BpQ42isNVhwk283hJc2HmC5Va5hf8xwTgK/UxQcKGvQLGF3gKlFvoLFFroMVBmoc9AkYWeDhNyC1Xh9aJLeYV+Jyiw0Os+KLHQe6C0Qv+BwgoDBMoqDBEoqtCECJRUOPz2e5gQV2jnYa7qllOYBvr5CEGFgVBIIYXPmJ/ghZueZ+hexOWd+w3q9ycuwg5R2377DsapDflbX7rTFah+TbajQSij/aT/wNNF26FUvoELAAAAAAAAAAAAAAAAAAAAAAAAAAAA4G/4B9L3P1vg3y4/AAAAAElFTkSuQmCC",
            fit: BoxFit.cover,
            height: 100,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 8.0),
        
        Text(
          'Cuisine: ${restaurant.cuisines?.join(', ') ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 12.0, 
            fontStyle: FontStyle.italic, 
          ),
        ),
        const SizedBox(height: 4.0),
    
        Text(
          'Rating: ${restaurant.rating ?? 'N/A'}',
          style: const TextStyle(
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
        
        Text(
          'Price: ${restaurant.priceRange ?? 'N/A'}',
          style: const TextStyle(
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
        const SizedBox(height: 8.0),
        
        TextButton(
          onPressed: () {
            _popupOverlayEntry?.remove();
            _popupOverlayEntry = null;
          },
          child: const Text('Close'),
        ),
      ],
    ),
  ),
),

      ),
    );
    Overlay.of(context).insert(_popupOverlayEntry!);
  }



 @override
  Widget build(BuildContext context) {
     final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map restaurants'),
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
        child : FutureBuilder(
        future: _loadMarkers(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(-8.6705, 115.2126),
                    initialZoom: 12.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                    const Center(child: CircularProgressIndicator())
                  ],
                );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No restaurants found.'));
          } else {
            List<Restaurant> filteredRestaurants = filterRestaurants(snapshot.data!);
            _markers = filteredRestaurants.map((restaurant) {
              
              
              return Marker(
                point: LatLng(restaurant.latitude!, restaurant.longitude!),
                width: 80,
                height: 80,
                child:  GestureDetector(
                  onTap: () {
                    _showPopup(context, restaurant);
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 154, 57, 51),
                        size: 40,
                         ),                 
                    ],
                  ),
                ),
              );
            }).toList();
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(-8.6705, 115.2126),
                    initialZoom: 12.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        onPressed: _zoomIn,
                        tooltip: 'Zoom In',
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        onPressed: _zoomOut,
                        tooltip: 'Zoom Out',
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                     ),
                ),
              ],
            );
          }
        },
      ),
      ),
        ],
      ),
    );
  }
}