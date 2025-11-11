// D:\Mobile App\flutter_sistem_rs\lib\services\dompet_medis_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dompet_medis_model.dart';
import '../utils/app_env.dart';

class DompetMedisService {
  static String get baseUrl => '${AppEnv.baseUrl}/dompet_medis';

  /// Ambil semua deposit milik pengguna berdasarkan NIK
  static Future<List<DompetMedis>> fetchDompetMedisByNik(String nik) async {
    final url = Uri.parse('$baseUrl/user/$nik');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      // backend return { success: true, data: [...] }
      if (result['success'] == true && result['data'] is List) {
        return (result['data'] as List)
            .map((e) => DompetMedis.fromJson(e))
            .toList();
      } else {
        throw Exception('Format data dompet medis tidak sesuai');
      }
    } else {
      throw Exception(
        'Gagal memuat data dompet medis (${response.statusCode})',
      );
    }
  }
}
