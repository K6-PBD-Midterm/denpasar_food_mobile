import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  double _currentZoom = 12.0;
  bool _showPopup = false;
  LatLng _popupPosition = const LatLng(0, 0);

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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte de Denpasar, Bali'),
      ),
      body: Stack(
        children: [
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
                markers: [
                  
                  Marker(
                    point: const LatLng(-8.6705, 115.2126), // Position du marqueur
                    width: 80,
                    height: 80,
                    child:  GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPopup = !_showPopup;
                        }); // Afficher le popup au clic
                      },
                    
                      child: const Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 255, 0, 93),
                        size: 40,
                      ),
                  
                    ),
                  ) ,
          _showPopup? 
                  Marker(
                    point: const LatLng(-8.6505, 115.2126), // Position du marqueur
                    width: 300,
                    height: 100,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPopup = !_showPopup;
                        }); // Afficher le popup au clic
                      },
                      child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child : 
                    Row (
                      children: [
                       SizedBox(height: 4),
                            Image.network(
                              'https://media-cdn.tripadvisor.com/media/photo-o/2d/bb/a0/11/caption.jpg', 
                              width: 50,
                              height: 70,
                            ),
                        Column(
                           
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                          'YUME',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ), 
                            SizedBox(height: 6),
                            Text('Cuisine: Japanese, Sushi, Asian, Japanese Fusion'),
                            SizedBox(height: 3),
                            Text('Rating: 5'),
                            SizedBox(height: 3),
                            Text('Price: \$\$ - \$\$\$'),
                          ],
                        ),
                      ],
                    ),
                  ),
                    ),
                  ) : 
                  Marker(
                    point: const LatLng(-8.6405, 115.2126),
                   child: Container()),
                ],
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
