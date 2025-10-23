// dokter_by_poli_screenimport 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../models/poli_model.dart';
import '../../services/poli_service.dart';
import 'dokter_by_poli_screen.dart';
import '../../widgets/custom_topbar.dart';

class PoliScreen extends StatefulWidget {
  const PoliScreen({Key? key}) : super(key: key);

  @override
  State<PoliScreen> createState() => _PoliScreenState();
}

class _PoliScreenState extends State<PoliScreen> {
  late Future<List<Poli>> futurePoli;

  @override
  void initState() {
    super.initState();
    futurePoli = PoliService.fetchPoli();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Daftar Poli'
      ),
      body: FutureBuilder<List<Poli>>(
        future: futurePoli,
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
            return const Center(child: Text('Belum ada data poli tersedia.'));
          }

          final poliList = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: poliList.length,
            itemBuilder: (context, index) {
              final poli = poliList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    poli.namaPoli,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Kode: ${poli.kode}\nZona: ${poli.zona}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      poli.kode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DokterByPoliScreen(
                          idPoli: poli.idPoli,
                          namaPoli: poli.namaPoli,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
