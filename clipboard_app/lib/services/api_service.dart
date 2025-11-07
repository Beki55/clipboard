import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.get(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
}
