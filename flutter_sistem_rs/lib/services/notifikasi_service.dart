import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notifikasi_model.dart';
import '../utils/app_env.dart';

class NotifikasiService {
  static String get _baseUrl => '${AppEnv.baseUrl}/notifikasi';

  Future<List<Notifikasi>> fetchNotifikasiByNIK() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik') ?? prefs.getString('NIK');

    if (nik == null) {
      throw Exception('NIK tidak ditemukan, silakan login ulang.');
    }

    final response = await http.get(Uri.parse('$_baseUrl?nik=$nik'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List dataList = decoded['data'] is List
          ? decoded['data']
          : [decoded['data']];
      return dataList.map((e) => Notifikasi.fromJson(e)).toList();
    } else {
      print('❌ Error response body: ${response.body}');
      throw Exception('Gagal memuat notifikasi: ${response.body}');
    }
  }

  Future<void> ubahStatusDibaca(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'STATUS': true}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status notifikasi: ${response.body}');
    }
  }
}
