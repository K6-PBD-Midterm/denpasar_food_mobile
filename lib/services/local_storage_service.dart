// lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../models/local_user.dart';

class LocalStorageService {
  static const String _restaurantsKey = 'restaurants';
  static const String _usersKey = 'users';

  Future<List<Restaurant>> getRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_restaurantsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Restaurant.fromJson(json)).toList();
  }

  Future<void> saveRestaurants(List<Restaurant> restaurants) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(restaurants.map((r) => r.toJson()).toList());
    await prefs.setString(_restaurantsKey, jsonString);
  }

  Future<List<LocalUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => LocalUser.fromJson(json)).toList();
  }

  Future<void> saveUsers(List<LocalUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, jsonString);
  }
}