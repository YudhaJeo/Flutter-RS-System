import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../../utils/app_env.dart';
import '../models/poli_model.dart';

class PoliService {
  static Future<List<Poli>> fetchPoli() async {
    final url = Uri.parse('http://10.0.2.2:4100/poli');
    // final url = Uri.parse('${AppEnv.baseUrl}/poli');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Poli.fromJson(e)).toList();
      } else {
        throw Exception('Format data tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat data poli: ${response.statusCode}');
    }
  }
}
