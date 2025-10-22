// D:\Mobile App\flutter_sistem_rs\lib\models\dompet_medis_model.dart
class DompetMedis {
  final int idDeposit;
  final String noInvoice;
  final String namaPasien;
  final String nik;
  final String? namaBank;
  final double jumlahDeposit;
  final String tanggalDeposit;

  DompetMedis({
    required this.idDeposit,
    required this.noInvoice,
    required this.namaPasien,
    required this.nik,
    this.namaBank,
    required this.jumlahDeposit,
    required this.tanggalDeposit,
  });

  factory DompetMedis.fromJson(Map<String, dynamic> json) {
    return DompetMedis(
      idDeposit: json['IDDEPOSIT'] ?? 0,
      noInvoice: json['NOINVOICE'] ?? '-',
      namaPasien: json['NAMAPASIEN'] ?? '-',
      nik: json['NIK'] ?? '-',
      namaBank: json['NAMA_BANK'],
      jumlahDeposit:
          (json['JUMLAHDEPOSIT'] is int || json['JUMLAHDEPOSIT'] is double)
              ? json['JUMLAHDEPOSIT'].toDouble()
              : double.tryParse(json['JUMLAHDEPOSIT']?.toString() ?? '0') ?? 0.0,
      tanggalDeposit: json['TANGGALDEPOSIT'] ?? '-',
    );
  }
}
