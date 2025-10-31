// D:\Mobile App\flutter_sistem_rs\lib\models\dompet_medis_model.dart
class DompetMedis {
  final int idDeposit;
  final String noInvoice;
  final String namaPasien;
  final String nik;
  final String? namaBank;
  final double jumlahDeposit;
  final double saldoSisa;
  final String tanggalDeposit;
  final String? status;

  DompetMedis({
    required this.idDeposit,
    required this.noInvoice,
    required this.namaPasien,
    required this.nik,
    this.namaBank,
    required this.jumlahDeposit,
    required this.saldoSisa,
    required this.tanggalDeposit,
    this.status,
  });

  factory DompetMedis.fromJson(Map<String, dynamic> json) {
    return DompetMedis(
      idDeposit: json['IDDEPOSIT'] ?? 0,
      noInvoice: json['NOINVOICE'] ?? '-',
      namaPasien: json['NAMAPASIEN'] ?? '-',
      nik: json['NIK'] ?? '-',
      namaBank: json['NAMA_BANK'],
      jumlahDeposit: _parseToDouble(json['JUMLAH']),
      saldoSisa: _parseToDouble(json['SALDO_SISA']),
      tanggalDeposit: json['TANGGALDEPOSIT'] ?? '-',
      status: json['STATUS'],
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}