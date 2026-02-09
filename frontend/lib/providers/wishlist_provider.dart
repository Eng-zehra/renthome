import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/api_service.dart';

class WishlistProvider with ChangeNotifier {
  List<Property> _items = [];
  bool _isLoading = false;

  List<Property> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/wishlist/my');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _items = data.map((json) => Property.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(int propertyId) async {
    try {
      final response = await ApiService.post('/wishlist/toggle', {
        'property_id': propertyId,
      });

      if (response.statusCode == 200) {
        // Optimistic UI or just re-fetch
        await fetchWishlist();
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
    }
  }

  bool isSaved(int propertyId) {
    return _items.any((p) => p.id == propertyId);
  }
}
