class KritikSaran {
  final int idKritikSaran;
  final String? nik;
  final String jenis;
  final String pesan;
  final DateTime createdAt;
  final DateTime updatedAt;

  // opsional: untuk menampilkan nama pasien dari join pasien
  final String? namaPasien;

  KritikSaran({
    required this.idKritikSaran,
    this.nik,
    required this.jenis,
    required this.pesan,
    required this.createdAt,
    required this.updatedAt,
    this.namaPasien,
  });

  factory KritikSaran.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return KritikSaran(
      idKritikSaran: json['IDKRITIKSARAN'] is int
          ? json['IDKRITIKSARAN']
          : int.tryParse(json['IDKRITIKSARAN'].toString()) ?? 0,
      nik: json['NIK'],
      jenis: json['JENIS'] ?? '',
      pesan: json['PESAN'] ?? '',
      createdAt: _parseDate(json['CREATED_AT']),
      updatedAt: _parseDate(json['UPDATED_AT']),
      namaPasien: json['NAMAPASIEN'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NIK': nik,
      'JENIS': jenis,
      'PESAN': pesan,
    };
  }
}
