import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kritik_saran_model.dart';
import '../utils/app_env.dart';

class KritikSaranService {
  static String get _baseUrl => '${AppEnv.baseUrl}/kritik_saran';

  Future<List<KritikSaran>> fetchKritikSaranByNIK() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik') ?? prefs.getString('NIK');
    if (nik == null)
      throw Exception('NIK tidak ditemukan, silakan login ulang.');

    final response = await http.get(Uri.parse('$_baseUrl?nik=$nik'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List dataList = decoded['data'] is List
          ? decoded['data']
          : [decoded['data']];
      return dataList.map((e) => KritikSaran.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.body}');
    }
  }

  Future<KritikSaran> tambahKritikSaran({
    required String jenis,
    required String pesan,
    required DateTime createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik') ?? prefs.getString('NIK');
    if (nik == null)
      throw Exception('NIK tidak ditemukan, silakan login ulang.');

    final body = json.encode({
      'NIK': nik,
      'JENIS': jenis,
      'PESAN': pesan,
      'CREATED_AT': createdAt.toIso8601String(),
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return KritikSaran.fromJson(decoded['data']);
    } else {
      throw Exception('Gagal mengirim kritik/saran: ${response.body}');
    }
  }

  Future<void> hapusKritikSaran(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data: ${response.body}');
    }
  }
}
