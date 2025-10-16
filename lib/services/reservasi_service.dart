// D:\Mobile App\flutter_sistem_rs\lib\services\reservasi_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reservasi_model.dart';

class ReservasiService {
  static const String _baseUrl = 'http://10.0.2.2:4100/reservasi';

  Future<List<Reservasi>> fetchReservasiByNIK() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final nik = prefs.getString('nik') ?? prefs.getString('NIK');

      if (nik == null) {
        throw Exception('NIK tidak ditemukan. Silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?nik=$nik'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        final List<dynamic> jsonList = responseBody is List
            ? responseBody
            : [responseBody];

        return jsonList.map((json) {
          try {
            return Reservasi.fromJson(json);
          } catch (e) {
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Gagal memuat reservasi: ${response.body}');
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<Reservasi> tambahReservasi({
    required int idPoli,
    required int idDokter,
    String? keterangan,
    required String jamReservasi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik');
    
    if (nik == null) {
      throw Exception('NIK tidak ditemukan. Silakan login ulang.');
    }

    final Map<String, dynamic> payload = {
      'NIK': nik,
      'IDPOLI': idPoli,
      'IDDOKTER': idDokter,
      'STATUS': 'Menunggu',
      'TANGGALRESERVASI': DateTime.now().toIso8601String().split('T')[0],
      'JAMRESERVASI': jamReservasi,
    };

    // Tambahkan keterangan hanya jika tidak null
    if (keterangan != null && keterangan.trim().isNotEmpty) {
      payload['KETERANGAN'] = keterangan;
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      dynamic jsonResponse;

      try {
        final decoded = json.decode(response.body);
        jsonResponse = decoded is Map && decoded.containsKey('data')
            ? decoded['data']
            : decoded;

        return Reservasi.fromJson(jsonResponse);
      } catch (e) {
        return Reservasi(
          idReservasi: (jsonResponse is Map && jsonResponse['IDRESERVASI'] != null)
              ? jsonResponse['IDRESERVASI']
              : 0,
          nik: nik,
          idPoli: idPoli,
          idDokter: idDokter,
          tanggalReservasi: payload['TANGGALRESERVASI']!,
          status: 'Menunggu',
          namaLengkap: '',
          namaPoli: '',
          namaDokter: '',
          jamReservasi: jamReservasi,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } else {
      throw Exception('Gagal menambah reservasi: ${response.body}');
    }

  }

  Future<Reservasi> batalkanReservasi(dynamic idReservasi) async {
    final id = idReservasi is int
        ? idReservasi.toString()
        : idReservasi.toString();

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'STATUS': 'Dibatalkan'}),
    );

    developer.log(
      'Batalkan Reservasi Response:',
      name: 'ReservasiService.batalkanReservasi',
      error: {
        'URL': '$_baseUrl/$id',
        'Status Code': response.statusCode,
        'Body': response.body,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body)['data'];
      return Reservasi.fromJson(jsonResponse);
    } else {
      throw Exception('Gagal membatalkan reservasi: ${response.body}');
    }
  }

  Future<Reservasi> editReservasi(
    int idReservasi, {
    int? idPoli,
    int? idDokter,
    String? keterangan,
  }) async {
    final Map<String, dynamic> updateData = {};

    if (idPoli != null) updateData['IDPOLI'] = idPoli;
    if (idDokter != null) updateData['IDDOKTER'] = idDokter;
    if (keterangan != null) updateData['KETERANGAN'] = keterangan;

    final response = await http.put(
      Uri.parse('$_baseUrl/$idReservasi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body)['data'];
      return Reservasi.fromJson(jsonResponse);
    } else {
      throw Exception('Gagal mengubah reservasi');
    }
  }
}
