import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/api_service.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = false;
  String? _selectedCategory;

  List<Property> get properties => _filteredProperties;
  
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/properties');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _properties = data.map((json) => Property.fromJson(json)).toList();
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching properties: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _currentCity = 'All';
  String get currentCity => _currentCity;

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByCity(String city) {
    _currentCity = city;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProperties = _properties.where((p) {
      bool matchesCategory = (_selectedCategory == null || _selectedCategory == 'All') 
          ? true 
          : p.type.toLowerCase() == _selectedCategory!.toLowerCase();
      
      bool matchesCity = _currentCity == 'All' 
          ? true 
          : p.city.toLowerCase().contains(_currentCity.toLowerCase()) || 
            p.location.toLowerCase().contains(_currentCity.toLowerCase());

      return matchesCategory && matchesCity;
    }).toList();
    notifyListeners();
  }

  void searchProperties(String query) {
    if (query.isEmpty) {
      _applyFilters(); // Revert to city/category filters
    } else {
      _filteredProperties = _properties
          .where((p) => 
              p.title.toLowerCase().contains(query.toLowerCase()) ||
              p.city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> addProperty(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/properties', data);
      if (response.statusCode == 201) {
        await fetchProperties();
        return true;
      }
      debugPrint('Add Property Error: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error adding property exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProperty(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.put('/properties/$id', data);
      if (response.statusCode == 200) {
        await fetchProperties();
        return true;
      }
      debugPrint('Update Property Error: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error updating property exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProperty(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.delete('/properties/$id');
      if (response.statusCode == 200) {
        await fetchProperties();
        return true;
      }
      debugPrint('Delete Property Error: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error deleting property exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
