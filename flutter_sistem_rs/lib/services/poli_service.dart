// D:\Mobile App\flutter_sistem_rs\lib\services\poli_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/poli_model.dart';

class PoliService {
  static const String _baseUrl = 'http://10.0.2.2:4100/poli';
  // Jika nanti pakai AppEnv:
  // static String get _baseUrl => '${AppEnv.baseUrl}/poli';

  /// 🔹 Ambil semua data poli
  Future<List<Poli>> fetchAllPoli() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
        'Fetch All Poli Response',
        name: 'PoliService.fetchAllPoli',
        error: {
          'Status Code': response.statusCode,
          'Body': response.body,
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body is List) {
          return body.map((json) => Poli.fromJson(json)).toList();
        } else if (body is Map && body.containsKey('data')) {
          final List<dynamic> dataList = body['data'];
          return dataList.map((json) => Poli.fromJson(json)).toList();
        } else {
          throw Exception('Format respons tidak dikenali');
        }
      } else {
        throw Exception('Gagal memuat poli: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log(
        'Error fetchAllPoli',
        name: 'PoliService',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// 🔹 Ambil poli berdasarkan ID
  Future<Poli> fetchPoliById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
        'Fetch Poli By ID',
        name: 'PoliService.fetchPoliById',
        error: {
          'URL': '$_baseUrl/$id',
          'Status Code': response.statusCode,
          'Body': response.body,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Poli.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Poli tidak ditemukan');
      } else {
        throw Exception('Gagal memuat data poli: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}