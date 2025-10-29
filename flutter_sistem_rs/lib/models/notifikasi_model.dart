class Notifikasi {
  final int idNotifikasi;
  final String nik;
  final String? namaPasien;
  final DateTime? tanggalReservasi;
  final String? namaPoli;
  final String? namaDokter;
  final String judul;
  final String pesan;
  final bool status;

  Notifikasi({
    required this.idNotifikasi,
    required this.nik,
    this.namaPasien,
    this.tanggalReservasi,
    this.namaPoli,
    this.namaDokter,
    required this.judul,
    required this.pesan,
    required this.status,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      idNotifikasi: json['IDNOTIFIKASI'] ?? 0,
      nik: json['NIK'] ?? '',
      namaPasien: json['NAMAPASIEN'],
      tanggalReservasi: json['TANGGALRESERVASI'] != null
          ? DateTime.tryParse(json['TANGGALRESERVASI'])
          : null,
      namaPoli: json['NAMAPOLI'],
      namaDokter: json['NAMADOKTER'],
      judul: json['JUDUL'] ?? '-',
      pesan: json['PESAN'] ?? '-',
      status: json['STATUS'] == 1 || json['STATUS'] == true,
    );
  }
}
