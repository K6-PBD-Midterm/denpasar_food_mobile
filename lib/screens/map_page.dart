import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // filter restau
  String _searchQuery = '';
  final List<String> _selectedCuisines = [];
  final List<String> _allCuisines = [];
  Key _dropdownKey = GlobalKey(); 

  // flutter map
  final MapController _mapController = MapController();
  double _currentZoom = 12.0;
  bool _showPopup = false;
  final List<Marker> _markers = [];
  

 void _generateMarkers(CookieRequest request) async {
  _markers.clear(); // Réinitialiser les marqueurs

  var restaurants = await fetchRestaurants(request);
  var restaurantsFiltered = filterRestaurants(restaurants);
   _allCuisines.addAll(_extractUniqueCuisines(restaurants));

  for (var restaurant in restaurantsFiltered) {
    if (restaurant.latitude != null && restaurant.longitude != null) {
      // Décalage pour le popup
      final popupOffset = LatLng(restaurant.latitude! + 0.0105, restaurant.longitude!);

      _markers.addAll([
        // Marqueur principal
        Marker(
          point: LatLng(restaurant.latitude!, restaurant.longitude!),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              setState(() {
                 print (" pin being cliked !  $_showPopup");
                _showPopup = !_showPopup; // Afficher ou masquer le popup
                print (" pin clicked !  $_showPopup");
              });
            },
            child: const Icon(
              Icons.location_pin,
              color: Color.fromARGB(255, 117, 12, 12),
              size: 40,
            ),
          ),
        ),

        // Popup uniquement si _showPopup est vrai
        if (_showPopup)
          Marker(
            point: popupOffset,
            width: 300,
            height: 120,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showPopup = !_showPopup; // Fermer le popup
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      restaurant.imageUrl ?? 'https://png.pngtree.com/png-vector/20221125/ourmid/pngtree-no-image-available-icon-flatvector-illustration-pic-design-profile-vector-png-image_40966566.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        for (var cuisine in restaurant.cuisines ?? [])
                          Chip(label: Text(cuisine)),
                        Text('Rating: ${restaurant.rating ?? 'N/A'}'),
                        Text('Price: ${restaurant.priceRange ?? 'N/A'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ]);
    }
  }

  setState(() {}); // Rafraîchir l'interface pour afficher les marqueurs
}


@override
void initState() {
  super.initState();
  print ("init state show pop up $_showPopup");
  // Initialiser le CookieRequest
  final request = CookieRequest();
  _generateMarkers(request); // Appeler _generateMarkers avec la requête
 
}
  void _zoomIn() {
    setState(() {
      _currentZoom += 1; // Incrémenter le zoom
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1; // Décrémenter le zoom
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }
   Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    try {
      final response = await request.get('https://denpasar-food.vercel.app/json/');
      List<Restaurant> listRestaurant = [];
      print ("response restau list $response §§§§§§§§§§§§§§§§§§");
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
    if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        restaurants = restaurants.where((restaurant) {
        return (restaurant.name?.toLowerCase().contains(query) ?? false) ||
              (restaurant.address?.toLowerCase().contains(query) ?? false) ||
              (restaurant.description?.toLowerCase().contains(query) ?? false);
      }).toList();
} else if (_selectedCuisines.isNotEmpty) {
      restaurants = restaurants.where((restaurant) {
        return restaurant.cuisines!.any((cuisine) => _selectedCuisines.contains(cuisine));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map restaurants'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child:
           Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
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
          FlutterMap(
            mapController: _mapController, // Associer le contrôleur
            options: MapOptions(
              initialCenter: const LatLng(-8.6705, 115.2126), // Centre initial
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _markers, // Ajouter les marqueurs
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
      ),
    );
  }
}
