import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000";

  // Guarda el token en SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }

  // Obtiene el token de SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  // Elimina el token (logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }

  // Construye headers con Content-Type y Bearer token si existe
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers();
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data,
      {bool auth = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = auth
        ? await _headers()
        : {'Content-Type': 'application/json'};
    return http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers();
    return http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _headers();
    return http.delete(url, headers: headers);
  }
}