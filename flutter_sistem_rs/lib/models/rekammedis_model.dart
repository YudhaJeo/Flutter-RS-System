class RekamMedis {
  final String nik;
  final String jenis;
  final String tanggal;
  final int? idRawatJalan;
  final int? idRawatInap;

  RekamMedis({
    required this.nik,
    required this.jenis,
    required this.tanggal,
    this.idRawatJalan,
    this.idRawatInap,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      nik: json['NIK'] ?? '',
      jenis: json['JENIS'] ?? '-',
      tanggal: json['TANGGAL'] ?? '',
      idRawatJalan: json['IDRIWAYATJALAN'],
      idRawatInap: json['IDRIWAYATINAP'],
    );
  }
}