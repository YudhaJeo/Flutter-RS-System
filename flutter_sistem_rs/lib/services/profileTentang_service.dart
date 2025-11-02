import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profileTentang_model.dart';

class ProfileTentangService {
  static const String _baseUrl = 'http://10.0.2.2:4100/profile_tentang';

  static Future<ProfileTentang?> fetchProfileTentang() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Beberapa API bisa kirim data tunggal (Map) atau List
        final Map<String, dynamic> dataMap = decoded is List && decoded.isNotEmpty
            ? decoded[0] as Map<String, dynamic>
            : decoded is Map<String, dynamic>
                ? decoded
                : {};

        if (dataMap.isEmpty) {
          throw Exception('Data profil kosong atau tidak valid.');
        }

        return ProfileTentang.fromJson(dataMap);
      } else {
        print('❌ Error response body: ${response.body}');
        throw Exception('Gagal memuat profil: ${response.body}');
      }
    } catch (e) {
      print('⚠️ fetchProfileTentang Error: $e');
      rethrow;
    }
  }
}
