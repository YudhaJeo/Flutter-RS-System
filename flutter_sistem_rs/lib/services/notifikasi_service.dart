import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  static const String _baseUrl = 'http://10.0.2.2:4100/notifikasi';

  /// Ambil daftar notifikasi berdasarkan NIK user yang login
  Future<List<Notifikasi>> fetchNotifikasiByNIK() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik') ?? prefs.getString('NIK');
    if (nik == null) throw Exception('NIK tidak ditemukan, silakan login ulang.');

    final response = await http.get(Uri.parse('$_baseUrl?nik=$nik'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List dataList =
          decoded['data'] is List ? decoded['data'] : [decoded['data']];
      return dataList.map((e) => Notifikasi.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat notifikasi: ${response.body}');
    }
  }

  /// Tandai notifikasi sebagai sudah dibaca
  Future<void> ubahStatusDibaca(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/status/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'STATUS': true}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status notifikasi: ${response.body}');
    }
  }

  /// Hapus notifikasi berdasarkan ID
  Future<void> hapusNotifikasi(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus notifikasi: ${response.body}');
    }
  }
}
