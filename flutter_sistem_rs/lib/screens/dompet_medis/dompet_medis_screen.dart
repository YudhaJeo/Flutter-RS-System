// D:\Mobile App\flutter_sistem_rs\lib\screens\dompet_medis\dompet_medis_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dompet_medis_model.dart';
import '../../services/dompet_medis_service.dart';
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
    final nik = prefs.getString('nik'); // Pastikan kamu simpan NIK saat login

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Dompet Medis'
      ),
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
            return const Center(
              child: Text('Belum ada deposit tercatat.'),
            );
          }

          final depositList = snapshot.data!;

          // 🔹 Urutkan berdasarkan nama pasien atau invoice (A-Z)
          depositList.sort((a, b) =>
              a.noInvoice.toLowerCase().compareTo(b.noInvoice.toLowerCase()));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: depositList.length,
            itemBuilder: (context, index) {
              final deposit = depositList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Colors.blue),
                  title: Text(
                    deposit.noInvoice,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${deposit.namaPasien}'),
                      if (deposit.namaBank != null)
                        Text('Bank: ${deposit.namaBank}'),
                      Text('Tanggal: ${deposit.tanggalDeposit}'),
                    ],
                  ),
                  trailing: Text(
                    'Rp ${deposit.jumlahDeposit.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
