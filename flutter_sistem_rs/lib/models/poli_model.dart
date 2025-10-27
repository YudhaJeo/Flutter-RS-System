class Poli {
  final int idPoli;
  final String namaPoli;
  final String kode;
  final String zona;
  final int jumlahDokter;

  Poli({
    required this.idPoli,
    required this.namaPoli,
    required this.kode,
    required this.zona,
    this.jumlahDokter = 0,
  });

  factory Poli.fromJson(Map<String, dynamic> json) {
    return Poli(
      idPoli: json['IDPOLI'] is int
          ? json['IDPOLI']
          : int.tryParse(json['IDPOLI']?.toString() ?? '0') ?? 0,
      namaPoli: json['NAMAPOLI']?.toString() ?? 'Tidak diketahui',
      kode: json['KODE']?.toString() ?? '-',
      zona: json['ZONA']?.toString() ?? '-',
      jumlahDokter: json['JUMLAH_DOKTER'] == null
    ? 0
    : int.tryParse(json['JUMLAH_DOKTER'].toString()) ?? 0,
    );
  }
}
