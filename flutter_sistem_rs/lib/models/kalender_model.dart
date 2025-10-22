class Kalender {
  final int id;
  final int? idDokter;
  final String tanggal;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  // (Opsional) tambahan informasi hasil join tabel dokter
  final String? namaDokter;

  Kalender({
    required this.id,
    this.idDokter,
    required this.tanggal,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
    this.namaDokter,
  });

  factory Kalender.fromJson(Map<String, dynamic> json) {
    int? _parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    DateTime _parseDateTimeSafely(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return Kalender(
      id: _parseIntSafely(json['ID']) ?? 0,
      idDokter: _parseIntSafely(json['IDDOKTER']),
      tanggal: json['TANGGAL'] ?? '',
      status: json['STATUS'] ?? 'tidak diketahui',
      keterangan: json['KETERANGAN'],
      createdAt: _parseDateTimeSafely(json['CREATED_AT']),
      updatedAt: _parseDateTimeSafely(json['UPDATED_AT']),
      namaDokter: json['NAMADOKTER'], // opsional jika API join dengan tabel dokter
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDDOKTER': idDokter,
      'TANGGAL': tanggal,
      'STATUS': status,
      'KETERANGAN': keterangan,
    };
  }

  // Getter opsional untuk mempermudah logika tampilan
  bool get isLibur => status.toLowerCase() == 'libur';
  String get formattedTanggal => tanggal.split('T').first;
}
