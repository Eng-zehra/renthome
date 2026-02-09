import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  List<PaymentMethod> _methods = [];
  bool _isLoading = false;

  List<PaymentMethod> get methods => _methods;
  bool get isLoading => _isLoading;

  Future<void> fetchPaymentMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/payment');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _methods = data.map((json) => PaymentMethod.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPaymentMethod(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/payment', data);
      if (response.statusCode == 201) {
        await fetchPaymentMethods();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePaymentMethod(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.delete('/payment/$id');
      if (response.statusCode == 200) {
        await fetchPaymentMethods();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
