// D:\Mobile App\flutter_sistem_rs\lib\services\dokter_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dokter_model.dart';
import '../utils/app_env.dart';

class DokterService {
  static Future<List<Dokter>> fetchAllDokter() async {
    final url = Uri.parse('${AppEnv.baseUrl}/dokter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Dokter.fromJson(e)).toList();
      } else {
        throw Exception('Format data dokter tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat data dokter: ${response.statusCode}');
    }
  }

  static Future<List<Dokter>> fetchDokterByPoli(int idPoli) async {
    final url = Uri.parse('${AppEnv.baseUrl}/dokter/poli/$idPoli');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Dokter.fromJson(e)).toList();
      } else {
        throw Exception('Format data dokter tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat data dokter: ${response.statusCode}');
    }
  }
}
