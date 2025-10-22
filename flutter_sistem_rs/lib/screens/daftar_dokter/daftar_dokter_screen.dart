import 'package:flutter/material.dart';
import '../../models/dokter_model.dart';
import '../../services/dokter_service.dart';
import '../../widgets/jadwal_dokter_modal.dart';

class DaftarDokterScreen extends StatefulWidget {
  const DaftarDokterScreen({super.key});

  @override
  State<DaftarDokterScreen> createState() => _DaftarDokterScreenState();
}

class _DaftarDokterScreenState extends State<DaftarDokterScreen> {
  late Future<List<Dokter>> futureDokter;

  @override
  void initState() {
    super.initState();
    // ✅ Panggil endpoint untuk semua dokter (ubah sesuai endpoint backend kamu)
    futureDokter = DokterService.fetchAllDokter();
  }

  void _showJadwalDialog(Dokter dokter) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DokterJadwalModal(dokter: dokter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dokter'),
        backgroundColor: const Color.fromARGB(255, 66, 159, 235),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Dokter>>(
        future: futureDokter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
              child: Text('Belum ada data dokter tersedia.'),
            );
          }

          final dokterList = snapshot.data!;

          // 🔹 Urutkan berdasarkan nama dokter (A-Z)
          dokterList.sort(
              (a, b) => a.namaLengkap.toLowerCase().compareTo(b.namaLengkap.toLowerCase()));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: dokterList.length,
            itemBuilder: (context, index) {
              final dokter = dokterList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    dokter.namaLengkap,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    dokter.namaPoli,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: const Text(
                    'Lihat Jadwal',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _showJadwalDialog(dokter),
                ),
              );
            },
          );
        },
      ),
    );
  }
}