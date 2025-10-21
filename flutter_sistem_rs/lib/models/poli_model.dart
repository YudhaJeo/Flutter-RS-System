class Poli {
  final int idPoli;
  final String namaPoli;
  final String kode;
  final String zona;

  Poli({
    required this.idPoli,
    required this.namaPoli,
    required this.kode,
    required this.zona,
  });

  factory Poli.fromJson(Map<String, dynamic> json) {
    return Poli(
      idPoli: json['IDPOLI'] ?? 0,
      namaPoli: json['NAMAPOLI'] ?? 'Tidak diketahui',
      kode: json['KODE'] ?? '-',
      zona: json['ZONA'] ?? '-',
    );
  }
}
