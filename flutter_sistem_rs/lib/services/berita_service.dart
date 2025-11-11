// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\services\berita_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita_model.dart';
import '../utils/app_env.dart';

class BeritaService {
  static String get baseUrl => '${AppEnv.baseUrl}/berita';

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
