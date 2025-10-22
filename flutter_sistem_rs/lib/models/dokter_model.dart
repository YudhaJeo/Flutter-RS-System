// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\models\dokter_model.dart
class Dokter {
  final int idDokter;
  final int idPoli;
  final String namaLengkap;
  final String namaPoli;
  final String jadwalPraktek;
  final String? fotoProfil;

  Dokter({
    required this.idDokter,
    required this.idPoli,
    required this.namaLengkap,
    required this.namaPoli,
    required this.jadwalPraktek,
    this.fotoProfil,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      idDokter: json['IDDOKTER'] ?? 0,
      idPoli: json['IDPOLI'] ?? 0,
      namaLengkap: json['NAMALENGKAP'] ?? '-',
      namaPoli: json['NAMAPOLI'] ?? '-',
      jadwalPraktek: json['JADWALPRAKTEK'] ?? '-',
      fotoProfil: json['FOTOPROFIL'],
    );
  }
}
