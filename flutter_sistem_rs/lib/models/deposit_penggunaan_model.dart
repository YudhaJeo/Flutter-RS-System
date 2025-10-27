// D:\Mobile App\flutter_sistem_rs\lib\models\deposit_penggunaan_model.dart
class DepositPenggunaan {
  final int idPenggunaan;
  final String noDeposit;
  final String noInvoice;
  final double jumlahPemakaian;
  final String tanggalPemakaian;

  DepositPenggunaan({
    required this.idPenggunaan,
    required this.noDeposit,
    required this.noInvoice,
    required this.jumlahPemakaian,
    required this.tanggalPemakaian,
  });

  factory DepositPenggunaan.fromJson(Map<String, dynamic> json) {
    return DepositPenggunaan(
      idPenggunaan: json['IDPENGGUNAAN'] ?? 0,
      noDeposit: json['NODEPOSIT'] ?? '-',
      noInvoice: json['NOINVOICE'] ?? '-',
      jumlahPemakaian: double.tryParse(json['JUMLAH_PEMAKAIAN'].toString()) ?? 0.0,
      tanggalPemakaian: json['TANGGALPEMAKAIAN'] ?? '-',
    );
  }
}
