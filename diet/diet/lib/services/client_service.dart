import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

class ClientService {
  final String baseUrl = "http://localhost:8000/api/clients";

  Future<List<ClientModel>> getClients() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);

        return body.map((dynamic item) => ClientModel.fromJson(item)).toList();
      } else {
        throw Exception('Veri çekilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<bool> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(clientData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Kayıt oluşturulamadı.');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
