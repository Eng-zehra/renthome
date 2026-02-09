import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api'; 

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Use standard key
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<String?> uploadImage(Uint8List bytes, String filename) async {
    try {
      String? token = await getToken();
      // Notice we use baseUrl but without /api for the root upload route
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8080/api/upload'));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: MediaType('image', filename.split('.').last),
      );

      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return 'http://127.0.0.1:8080${data['url']}';
      }
      return null;
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }
}
