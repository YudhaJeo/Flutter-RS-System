import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../../utils/app_env.dart';
import '../models/kalender_model.dart';

class KalenderService {
  static Future<List<Kalender>> fetchKalender() async {
    final url = Uri.parse('http://10.0.2.2:4100/kalender');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Kalender.fromJson(e)).toList();
      } else {
        throw Exception('Format data tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat data poli: ${response.statusCode}');
    }
  }
}
