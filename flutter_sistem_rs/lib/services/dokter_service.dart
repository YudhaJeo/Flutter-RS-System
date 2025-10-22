import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dokter_model.dart';

class DokterService {
  static Future<List<Dokter>> fetchDokterByPoli(int idPoli) async {
    final url = Uri.parse('http://10.0.2.2:4100/dokter/poli/$idPoli');
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
