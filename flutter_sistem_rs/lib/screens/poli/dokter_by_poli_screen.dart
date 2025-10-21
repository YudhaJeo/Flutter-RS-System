// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\screens\poli\dokter_by_poli_screen.dart
import 'package:flutter/material.dart';
import '../../models/dokter_model.dart';
import '../../services/dokter_service.dart';
import '../../widgets/jadwal_dokter_modal.dart';

class DokterByPoliScreen extends StatefulWidget {
  final int idPoli;
  final String namaPoli;

  const DokterByPoliScreen({
    Key? key,
    required this.idPoli,
    required this.namaPoli,
  }) : super(key: key);

  @override
  State<DokterByPoliScreen> createState() => _DokterByPoliScreenState();
}

class _DokterByPoliScreenState extends State<DokterByPoliScreen> {
  late Future<List<Dokter>> futureDokter;

  @override
  void initState() {
    super.initState();
    futureDokter = DokterService.fetchDokterByPoli(widget.idPoli);
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
        title: Text('Dokter - ${widget.namaPoli}'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Dokter>>(
        future: futureDokter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada dokter di poli ini.'));
          }

          final dokters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dokters.length,
            itemBuilder: (context, index) {
              final dokter = dokters[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    dokter.namaLengkap,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Text(
                    'Lihat Detail',
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
