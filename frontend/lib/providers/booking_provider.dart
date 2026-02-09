import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _myBookings = [];
  String? _lastError;
  
  bool get isLoading => _isLoading;
  List<dynamic> get myBookings => _myBookings;
  String? get lastError => _lastError;

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/bookings', bookingData);
      _isLoading = false;
      
      if (response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        // Parse error message from server
        try {
          final errorData = jsonDecode(response.body);
          _lastError = errorData['message'] ?? 'Failed to book. Please try again.';
        } catch (e) {
          _lastError = 'Failed to book. Please try again.';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _lastError = 'Network error. Please check your connection.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/bookings/my');
      if (response.statusCode == 200) {
        _myBookings = jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DateTime> _blockedDates = [];
  List<DateTime> get blockedDates => _blockedDates;

  Future<void> fetchBlockedDates(int propertyId) async {
    try {
      final response = await ApiService.get('/bookings/property/$propertyId/dates');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _blockedDates = [];
        for (var item in data) {
           DateTime start = DateTime.parse(item['check_in']);
           DateTime end = DateTime.parse(item['check_out']);
           // Block days from check_in up to (but not including) check_out
           while (start.isBefore(end)) {
             _blockedDates.add(start);
             start = start.add(const Duration(days: 1));
           }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching blocked dates: $e');
    }
  }
}
