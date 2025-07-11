import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/university.dart';

class UniversityApiService {
  static const String _baseUrl = 'http://universities.hipolabs.com';

  Future<List<University>> searchUniversitiesByCountry(String country) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?country=$country'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => University.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load universities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load universities: $e');
    }
  }

  Future<List<University>> getAllUniversities() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => University.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load universities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load universities: $e');
    }
  }
}
