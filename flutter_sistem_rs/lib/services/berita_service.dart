import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita_model.dart';

class BeritaService {
  static const String baseUrl = 'http://10.0.2.2:4100/berita';

  static Future<List<Berita>> fetchAllBerita() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((e) => Berita.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data berita (${response.statusCode})');
    }
  }
}
