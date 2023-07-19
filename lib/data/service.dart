import 'package:http/http.dart' as http;
import 'dart:convert';
import 'endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  static String baseUrl = "https://e926.net";

  static Future<void> _saveBaseUrl(String newBaseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', newBaseUrl);
  }

  static Future<void> _loadBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
  }

  static void setBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    _saveBaseUrl(newBaseUrl);
  }

  static Future<dynamic> getResult(String name) async {
    await _loadBaseUrl(); // Load baseUrl on app start
    String link = ApiEndpoint.getResult(name);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> getResultNext(int _currentPage, String name) async {
    String link = ApiEndpoint.getResultNext(_currentPage, name);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> getAutocomplete(String keyword) async {
    String link = ApiEndpoint.getkeyword(keyword);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> getPosts() async {
    String link = ApiEndpoint.getpost();
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> getPostsNext(int _currentPage) async {
    String link = ApiEndpoint.getPostNext(_currentPage);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> gethots() async {
    String link = ApiEndpoint.gethots();
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> gethotsNext(int _currentPage) async {
    String link = ApiEndpoint.gethotsNext(_currentPage);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['posts'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  static Future<dynamic> getDetail(String imageID) async {
    String link = ApiEndpoint.getDetail(imageID);
    final response = await http.get(Uri.parse('$baseUrl$link'));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData['post'];
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }
}
