import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekammedis_model.dart';
import '../utils/app_env.dart';

class RekamMedisService {
  static String get _baseUrl => '${AppEnv.baseUrl}/rekam_medis';

  Future<List<RekamMedis>> fetchRekamMedisSaya() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik') ?? prefs.getString('NIK');

    if (nik == null) {
      throw Exception('NIK tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(Uri.parse('$_baseUrl?nik=$nik'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List dataList = body['data'] ?? [];
      return dataList.map((e) => RekamMedis.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat rekam medis: ${response.body}');
    }
  }

  Future<List<RekamMedis>> fetchDetailRekamMedis(String nik) async {
    final response = await http.get(Uri.parse('$_baseUrl/detail/$nik'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List dataList = body['data'] ?? [];
      return dataList.map((e) => RekamMedis.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat detail rekam medis: ${response.body}');
    }
  }
}
