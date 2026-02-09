import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  double _totalRevenue = 0.0;
  int _totalUsers = 0;
  int _totalProperties = 0;
  int _totalBookings = 0;
  int _pendingBookings = 0;
  List<Map<String, dynamic>> _chartData = [];
  List<dynamic> _bookings = [];

  bool get isLoading => _isLoading;
  double get totalRevenue => _totalRevenue;
  int get totalUsers => _totalUsers;
  int get totalProperties => _totalProperties;
  int get totalBookings => _totalBookings;
  int get pendingBookings => _pendingBookings;
  List<Map<String, dynamic>> get chartData => _chartData;
  List<dynamic> get bookings => _bookings;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/admin/stats');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _totalRevenue = double.tryParse(data['totalRevenue']?.toString() ?? '0') ?? 0.0;
        _totalUsers = data['totalUsers'] ?? 0;
        _totalProperties = data['totalProperties'] ?? 0;
        _totalBookings = data['totalBookings'] ?? 0;
        _pendingBookings = data['pendingBookings'] ?? 0;
        
        List<dynamic> rawChartData = data['chartData'] ?? [];
        _chartData = rawChartData.map((item) {
          return {
            'date': item['date'],
            'dailyRevenue': double.tryParse(item['dailyRevenue']?.toString() ?? '0') ?? 0.0,
          };
        }).toList().cast<Map<String, dynamic>>();
        
      } else {
        debugPrint('Fetch Admin Stats Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch Admin Stats Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/admin/bookings');
      debugPrint('Fetch Bookings Status: ${response.statusCode}');
      debugPrint('Fetch Bookings Response: ${response.body}');
      
      if (response.statusCode == 200) {
        _bookings = jsonDecode(response.body);
        debugPrint('Bookings loaded: ${_bookings.length}');
      } else {
        debugPrint('Failed to fetch bookings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch Admin Bookings Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(dynamic bookingId, String status) async {
    try {
      final response = await ApiService.patch('/admin/bookings/${bookingId.toString()}/status', {
        'status': status
      });
      if (response.statusCode == 200) {
        // Refresh local data
        final index = _bookings.indexWhere((b) => b['id'].toString() == bookingId.toString());
        if (index != -1) {
          _bookings[index]['status'] = status;
          fetchDashboardStats(); // Refresh stats (count, revenue, etc.)
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update Booking Status Error: $e');
      return false;
    }
  }
}
