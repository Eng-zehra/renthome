import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Login Failed: ${response.statusCode} - ${response.body}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login Catch Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Registration Failed: ${response.statusCode} - ${response.body}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is TypeError) {
        debugPrint('Registration JSON Parse Error: $e');
      }
      debugPrint('Registration Catch Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.put('/auth/profile', data);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _user = UserModel.fromJson(userData);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Profile Update Failed: ${response.statusCode} - ${response.body}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Profile Update Catch Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      });

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Forgot Password Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
