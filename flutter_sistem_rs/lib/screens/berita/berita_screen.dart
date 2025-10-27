// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\screens\berita\berita_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Berita>> _beritaFuture;

  @override
  void initState() {
    super.initState();
    _beritaFuture = BeritaService.fetchAllBerita();
  }

  // 🔹 Format tanggal agar lebih enak dibaca
  String formatTanggal(String raw) {
    try {
      String clean = raw.replaceAll('TIB', 'T');
      final date = DateTime.parse(clean);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      print('Error parsing tanggal: $raw -> $e');
      return raw;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua Berita')),
      body: FutureBuilder<List<Berita>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat berita: ${snapshot.error}'),
            );
          }

          final beritaList = snapshot.data ?? [];
          if (beritaList.isEmpty) {
            return const Center(child: Text('Belum ada berita.'));
          }

          // Urutkan dari yang terbaru
          beritaList.sort((a, b) => b.id.compareTo(a.id));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              final berita = beritaList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      berita.pratinjau,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(
                    berita.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        berita.deskripsiSingkat,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTanggal(berita.tanggalUpload),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Buka di Browser?'),
                        content: const Text(
                            'Apakah kamu yakin ingin membuka berita ini di browser?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Buka'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _launchURL(berita.url);
                    }
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
