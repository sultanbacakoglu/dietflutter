import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/auth';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', data['Username'] ?? username);

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['Message'] ?? 'Giriş başarısız.');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
