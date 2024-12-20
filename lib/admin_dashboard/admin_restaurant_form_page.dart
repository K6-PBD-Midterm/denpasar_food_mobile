// lib/admin_dashboard/admin_restaurant_form_page.dart (continued)

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/models/restaurant.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';
import 'dart:convert';

class AdminRestaurantFormPage extends StatefulWidget {
  final Restaurant? restaurant;

  const AdminRestaurantFormPage({super.key, this.restaurant});

  @override
  _AdminRestaurantFormPageState createState() => _AdminRestaurantFormPageState();
}

class _AdminRestaurantFormPageState extends State<AdminRestaurantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cuisinesController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _rankingController = TextEditingController();
  final _detailedAddressController = TextEditingController();
  final _reviewsPerRatingController = TextEditingController();
  final _reviewKeywordsController = TextEditingController();
  final _openHoursController = TextEditingController();
  final _menuLinkController = TextEditingController();
  final _deliveryUrlController = TextEditingController();
  final _dietsController = TextEditingController();
  final _mealTypesController = TextEditingController();
  final _diningOptionsController = TextEditingController();
  final _ownerTypesController = TextEditingController();
  final _topTagsController = TextEditingController();
  bool _isOpen = false;
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _showAdvancedFields = false;

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      _idController.text = widget.restaurant!.id.toString();
      _nameController.text = widget.restaurant!.name ?? '';
      _descriptionController.text = widget.restaurant!.description ?? '';
      _cuisinesController.text = widget.restaurant!.cuisines?.join(', ') ?? '';
      _addressController.text = widget.restaurant!.address ?? '';
      _phoneController.text = widget.restaurant!.phone ?? '';
      _latitudeController.text = widget.restaurant!.latitude?.toString() ?? '';
      _longitudeController.text = widget.restaurant!.longitude?.toString() ?? '';
      _websiteController.text = widget.restaurant!.website ?? '';
      _imageUrlController.text = widget.restaurant!.imageUrl ?? '';
      _priceRangeController.text = widget.restaurant!.priceRange ?? '';
      _rankingController.text = widget.restaurant!.ranking?.toString() ?? '';
      _detailedAddressController.text = widget.restaurant!.detailedAddress?.toString() ?? '';
      _reviewsPerRatingController.text = widget.restaurant!.reviewsPerRating?.toString() ?? '';
      _reviewKeywordsController.text = widget.restaurant!.reviewKeywords?.join(', ') ?? '';
      _openHoursController.text = widget.restaurant!.openHours?.toString() ?? '';
      _menuLinkController.text = widget.restaurant!.menuLink ?? '';
      _deliveryUrlController.text = widget.restaurant!.deliveryUrl ?? '';
      _dietsController.text = widget.restaurant!.diets?.join(', ') ?? '';
      _mealTypesController.text = widget.restaurant!.mealTypes?.join(', ') ?? '';
      _diningOptionsController.text = widget.restaurant!.diningOptions?.join(', ') ?? '';
      _ownerTypesController.text = widget.restaurant!.ownerTypes?.join(', ') ?? '';
      _topTagsController.text = widget.restaurant!.topTags?.join(', ') ?? '';
      _isOpen = widget.restaurant!.isOpen ?? false;
    }
  }

  Future<void> _saveRestaurant() async {
    if (_formKey.currentState!.validate()) {
      final newRestaurant = Restaurant(
        id: int.parse(_idController.text),
        name: _nameController.text,
        description: _descriptionController.text,
        cuisines: _cuisinesController.text.split(',').map((e) => e.trim()).toList(),
        address: _addressController.text,
        phone: _phoneController.text,
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
        website: _websiteController.text,
        imageUrl: _imageUrlController.text,
        priceRange: _priceRangeController.text,
        ranking: _rankingController.text.isNotEmpty ? json.decode(_rankingController.text) : null,
        detailedAddress: _detailedAddressController.text.isNotEmpty ? json.decode(_detailedAddressController.text) : null,
        reviewsPerRating: _reviewsPerRatingController.text.isNotEmpty ? Map<String, int>.from(json.decode(_reviewsPerRatingController.text)) : null,
        reviewKeywords: _reviewKeywordsController.text.split(',').map((e) => e.trim()).toList(),
        openHours: _openHoursController.text.isNotEmpty ? json.decode(_openHoursController.text) : null,
        menuLink: _menuLinkController.text,
        deliveryUrl: _deliveryUrlController.text,
        diets: _dietsController.text.split(',').map((e) => e.trim()).toList(),
        mealTypes: _mealTypesController.text.split(',').map((e) => e.trim()).toList(),
        diningOptions: _diningOptionsController.text.split(',').map((e) => e.trim()).toList(),
        ownerTypes: _ownerTypesController.text.isNotEmpty ? json.decode(_ownerTypesController.text) : null,
        topTags: _topTagsController.text.split(',').map((e) => e.trim()).toList(),
        isOpen: _isOpen,
      );

      List<Restaurant> existingRestaurants = await _localStorageService.getRestaurants();
      if (widget.restaurant == null) {
        existingRestaurants.add(newRestaurant);
      } else {
        existingRestaurants = existingRestaurants.map((restaurant) {
          return restaurant.id == newRestaurant.id ? newRestaurant : restaurant;
        }).toList();
      }
      await _localStorageService.saveRestaurants(existingRestaurants);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant == null ? 'Add Restaurant' : 'Edit Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Required Fields
                Text('Required Fields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'ID *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cuisinesController,
                  decoration: const InputDecoration(labelText: 'Cuisines *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cuisines';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the latitude';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the longitude';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(labelText: 'Website *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the website';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _saveRestaurant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.restaurant == null ? Colors.green : Colors.yellow,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.restaurant == null ? 'Add' : 'Save'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showAdvancedFields = !_showAdvancedFields;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_showAdvancedFields ? 'Hide Advanced' : 'Advanced'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                if (_showAdvancedFields)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text('Advanced Fields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceRangeController,
                        decoration: const InputDecoration(labelText: 'Price Range'),
                      ),
                      TextFormField(
                        controller: _rankingController,
                        decoration: const InputDecoration(labelText: 'Ranking'),
                      ),
                      TextFormField(
                        controller: _detailedAddressController,
                        decoration: const InputDecoration(labelText: 'Detailed Address'),
                      ),
                      TextFormField(
                        controller: _reviewsPerRatingController,
                        decoration: const InputDecoration(labelText: 'Reviews Per Rating'),
                      ),
                      TextFormField(
                        controller: _reviewKeywordsController,
                        decoration: const InputDecoration(labelText: 'Review Keywords'),
                      ),
                      TextFormField(
                        controller: _openHoursController,
                        decoration: const InputDecoration(labelText: 'Open Hours'),
                      ),
                      TextFormField(
                        controller: _menuLinkController,
                        decoration: const InputDecoration(labelText: 'Menu Link'),
                      ),
                      TextFormField(
                        controller: _deliveryUrlController,
                        decoration: const InputDecoration(labelText: 'Delivery URL'),
                      ),
                      TextFormField(
                        controller: _dietsController,
                        decoration: const InputDecoration(labelText: 'Diets'),
                      ),
                      TextFormField(
                        controller: _mealTypesController,
                        decoration: const InputDecoration(labelText: 'Meal Types'),
                      ),
                      TextFormField(
                        controller: _diningOptionsController,
                        decoration: const InputDecoration(labelText: 'Dining Options'),
                      ),
                      TextFormField(
                        controller: _ownerTypesController,
                        decoration: const InputDecoration(labelText: 'Owner Types'),
                      ),
                      TextFormField(
                        controller: _topTagsController,
                        decoration: const InputDecoration(labelText: 'Top Tags'),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isOpen,
                            onChanged: (bool? value) {
                              setState(() {
                                _isOpen = value ?? false;
                              });
                            },
                          ),
                          const Text('Is Open'),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}