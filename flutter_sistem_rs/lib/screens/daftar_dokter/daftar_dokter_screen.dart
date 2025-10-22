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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Cari Dokter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 50, 169, 248),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Dokter>>(
        future: futureDokter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data dokter tersedia.'));
          }

          final dokterList = snapshot.data!;
          dokterList.sort(
            (a, b) => a.namaLengkap.toLowerCase().compareTo(b.namaLengkap.toLowerCase()),
          );

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dokterList.length,
            itemBuilder: (context, index) {
              final dokter = dokterList[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FOTO DOKTER
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color.fromARGB(255, 139, 212, 255),
                        backgroundImage: dokter.fotoProfil != null
                            ? NetworkImage(dokter.fotoProfil!)
                            : null,
                        child: dokter.fotoProfil == null
                            ? const Icon(Icons.person, color: Colors.green, size: 35)
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // NAMA DOKTER
                      Text(
                        dokter.namaLengkap.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // KLINIK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Klinik',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dokter.namaPoli,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TOMBOL LIHAT JADWAL
                      InkWell(
                        onTap: () => _showJadwalDialog(dokter),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LIHAT JADWAL',
                            style: TextStyle(
                              color: Color.fromARGB(255, 50, 169, 248),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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