// D:\Mobile App\flutter_sistem_rs\lib\screens\dompet_medis\dompet_medis_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/dompet_medis_model.dart';
import '../../services/dompet_medis_service.dart';
import '../../services/deposit_penggunaan_service.dart';
import '../../models/deposit_penggunaan_model.dart';
import '../../widgets/custom_topbar.dart';

class DompetMedisScreen extends StatefulWidget {
  const DompetMedisScreen({super.key});

  @override
  State<DompetMedisScreen> createState() => _DompetMedisScreenState();
}

class _DompetMedisScreenState extends State<DompetMedisScreen> {
  late Future<List<DompetMedis>> futureDompetMedis;
  String? nikUser;

  @override
  void initState() {
    super.initState();
    _loadUserDompetMedis();
  }

  Future<void> _loadUserDompetMedis() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik'); // disimpan saat login

    if (nik != null && nik.isNotEmpty) {
      setState(() {
        nikUser = nik;
        futureDompetMedis = DompetMedisService.fetchDompetMedisByNik(nik);
      });
    } else {
      setState(() {
        futureDompetMedis = Future.error('Data pengguna tidak ditemukan');
      });
    }
  }

  String _formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  /// 🔹 Menampilkan dialog riwayat penggunaan deposit
  void _showRiwayatPenggunaanDialog(String noInvoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Penggunaan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: FutureBuilder<List<DepositPenggunaan>>(
            future: DepositPenggunaanService.fetchByNoInvoice(noInvoice),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Text(
                  'Gagal memuat data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Belum ada riwayat penggunaan deposit.');
              }

              final list = snapshot.data!;
              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final penggunaan = list[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. Deposit: ${penggunaan.noDeposit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jumlah Pemakaian: '
                            'Rp ${penggunaan.jumlahPemakaian.toStringAsFixed(0)}',
                          ),
                          Text(
                            'Tanggal: ${_formatTanggal(penggunaan.tanggalPemakaian)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(title: 'Dompet Medis'),
      body: FutureBuilder<List<DompetMedis>>(
        future: futureDompetMedis,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada deposit tercatat.'));
          }

          final depositList = snapshot.data!;
          depositList.sort(
            (a, b) =>
                a.noInvoice.toLowerCase().compareTo(b.noInvoice.toLowerCase()),
          );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: depositList.length,
            itemBuilder: (context, index) {
              final deposit = depositList[index];

              return GestureDetector(
                onTap: () => _showRiwayatPenggunaanDialog(deposit.noInvoice),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              deposit.noInvoice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Deposit',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 10),

                        // Detail Info
                        _buildInfoRow('Nama', deposit.namaPasien),
                        if (deposit.namaBank != null &&
                            deposit.namaBank!.isNotEmpty)
                          _buildInfoRow('Bank', deposit.namaBank!),
                        _buildInfoRow(
                          'Tanggal',
                          _formatTanggal(deposit.tanggalDeposit),
                        ),
                        const SizedBox(height: 8),

                        // Jumlah Deposit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jumlah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Rp ${deposit.jumlahDeposit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
