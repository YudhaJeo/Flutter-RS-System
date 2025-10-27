// D:\Mobile App\flutter_sistem_rs\lib\services\deposit_penggunaan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/deposit_penggunaan_model.dart';

class DepositPenggunaanService {
  static const String baseUrl = 'http://10.0.2.2:4100/deposit_penggunaan';

  static Future<List<DepositPenggunaan>> fetchByNoInvoice(String noInvoice) async {
    final url = Uri.parse('$baseUrl/deposit_penggunaan/invoice/$noInvoice');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true && result['data'] is List) {
        return (result['data'] as List)
            .map((e) => DepositPenggunaan.fromJson(e))
            .toList();
      } else {
        throw Exception('Format data tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat data penggunaan deposit');
    }
  }
}
