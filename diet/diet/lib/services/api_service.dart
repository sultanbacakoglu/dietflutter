import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  // LOGIN
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', data['Username'] ?? username);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? 'Giriş başarısız');
    }
  }

  // RANDEVULARI GETİR
  static Future<List<dynamic>> getAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Randevular yüklenemedi');
    }
  }

  // RANDEVU EKLE
  static Future<void> createAppointment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Randevu oluşturulamadı: ${response.body}');
    }
  }

  // ŞİFRE DEĞİŞTİR
  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'expert';

    final response = await http.put(
      Uri.parse('$baseUrl/users/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'currentPassword': currentPassword,
        'newPassword': newPassword
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['Message'] ?? 'Şifre değiştirilemedi');
    }
  }
}
