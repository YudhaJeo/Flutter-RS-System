// D:\Mobile App\flutter_sistem_rs\lib\models\reservasi_model.dart
class Reservasi {
  final int idReservasi;
  final String nik;
  final int? idPoli;
  final int? idDokter;
  final String tanggalReservasi;
  final String? jadwalPraktek;
  final String? jamReservasi;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Tambahan untuk informasi tambahan dari join (opsional)
  final String? namaLengkap;
  final String? namaPoli;
  final String? namaDokter;

  Reservasi({
    required this.idReservasi,
    required this.nik,
    this.idPoli,
    this.idDokter,
    required this.tanggalReservasi,
    this.jadwalPraktek,
    this.jamReservasi,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
    this.namaLengkap,
    this.namaPoli,
    this.namaDokter,
  });

  factory Reservasi.fromJson(Map<String, dynamic> json) {
    // Fungsi konversi yang robust untuk integer
    int? _parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Fungsi konversi yang robust untuk datetime
    DateTime _parseDateTimeSafely(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Reservasi(
      idReservasi: _parseIntSafely(json['IDRESERVASI']) ?? 0,
      nik: json['NIK'],
      idPoli: _parseIntSafely(json['IDPOLI']),
      idDokter: _parseIntSafely(json['IDDOKTER']),
      tanggalReservasi: json['TANGGALRESERVASI'] is DateTime
          ? (json['TANGGALRESERVASI'] as DateTime).toIso8601String().split('T')[0]
          : json['TANGGALRESERVASI'],
      jadwalPraktek: json['JADWALPRAKTEK'] is List
          ? (json['JADWALPRAKTEK'] as List).join(', ')
          : json['JADWALPRAKTEK']?.toString(),
      jamReservasi: json['JAMRESERVASI'],
      status: json['STATUS'] ?? 'Menunggu',
      keterangan: json['KETERANGAN'],
      createdAt: _parseDateTimeSafely(json['CREATED_AT']),
      updatedAt: _parseDateTimeSafely(json['UPDATED_AT']),
      namaLengkap: json['NAMALENGKAP'],
      namaPoli: json['NAMAPOLI'],
      namaDokter: json['NAMADOKTER'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NIK': nik,
      'IDPOLI': idPoli,
      'IDDOKTER': idDokter,
      'TANGGALRESERVASI': tanggalReservasi,
      'JADWALPRAKTEK': jadwalPraktek,
      'JAMRESERVASI': jamReservasi,
      'STATUS': status,
      'KETERANGAN': keterangan,
    };
  }

  // Metode untuk mendapatkan status yang dapat diubah
  bool get dapatDibatalkan => status == 'Menunggu';
  bool get dapatDiedit => status == 'Menunggu';
}
