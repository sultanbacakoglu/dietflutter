import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://localhost:8000/api/users';

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'expert';

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'currentPassword': currentPassword,
          'newPassword': newPassword
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['Message'] ?? 'Şifre değiştirilemedi');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
