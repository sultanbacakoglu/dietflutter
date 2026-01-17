import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diet_model.dart';

class DietService {
  static const String baseUrl = 'http://localhost:8000/api/dietlists';

  // 1. Tüm Diyet Listelerini Getir
  // apiService.getDietLists()
  Future<List<DietModel>> getDietLists() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => DietModel.fromJson(item)).toList();
      } else {
        throw Exception('Listeler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // 2. Tek Bir Listenin Detayını Getir
  // apiService.getDietListById(id)
  Future<DietModel> getDietListById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return DietModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Detay yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // 3. Yeni Liste Oluştur
  // apiService.createDietList(data)
  Future<void> createDietList(DietModel diet) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(diet.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Kaydedilemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
