// D:\Mobile App\flutter_sistem_rs\lib\models\poli_model.dart
class Poli {
  final int idPoli;
  final String namaPoli;
  final String? keterangan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Poli({
    required this.idPoli,
    required this.namaPoli,
    this.keterangan,
    this.createdAt,
    this.updatedAt,
  });

  factory Poli.fromJson(Map<String, dynamic> json) {
    // Konversi aman untuk integer
    int _parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Konversi aman untuk DateTime
    DateTime? _parseDateTimeSafely(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return Poli(
      idPoli: _parseIntSafely(json['IDPOLI']),
      namaPoli: json['NAMAPOLI'] ?? '',
      keterangan: json['KETERANGAN'],
      createdAt: _parseDateTimeSafely(json['CREATED_AT']),
      updatedAt: _parseDateTimeSafely(json['UPDATED_AT']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDPOLI': idPoli,
      'NAMAPOLI': namaPoli,
      'KETERANGAN': keterangan,
    };
  }

  @override
  String toString() => namaPoli;
}