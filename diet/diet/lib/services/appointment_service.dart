import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  static const String baseUrl = 'http://localhost:8000/api/appointments';

  // Randevuları Getir
  Future<List<dynamic>> getAppointments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Randevular yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // Yeni Randevu Ekle
  Future<void> createAppointment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      String errorMessage = "Randevu oluşturulamadı.";
      try {
        errorMessage = response.body;
      } catch (_) {}

      throw Exception(errorMessage);
    }
  }
}
