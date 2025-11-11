// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\models\berita_model.dart
import '../utils/app_env.dart';

class Berita {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final String pratinjau;
  final String url;
  final String tanggalUpload;

  Berita({
    required this.id,
    required this.judul,
    required this.deskripsiSingkat,
    required this.pratinjau,
    required this.url,
    required this.tanggalUpload,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
  final rawPratinjau = json['PRATINJAU'];
  String pratinjauUrl = '';

  if (rawPratinjau != null && rawPratinjau.toString().isNotEmpty) {
    if (rawPratinjau.toString().startsWith('http')) {
      pratinjauUrl = rawPratinjau;
    } else {
      final path = rawPratinjau.toString().startsWith('/')
          ? rawPratinjau
          : '/$rawPratinjau';
      pratinjauUrl = '${AppEnv.baseUrl}$path';
    }
  }

  return Berita(
    id: json['IDBERITA'],
    judul: json['JUDUL'],
    deskripsiSingkat: json['DESKRIPSISINGKAT'],
    pratinjau: pratinjauUrl,
    url: json['URL'] ?? '',
    tanggalUpload: json['CREATED_AT'],
  );
}
}
