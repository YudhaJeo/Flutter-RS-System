import 'package:flutter/material.dart';
import '../models/dokter_model.dart';
import 'custom_topbar.dart';

class DokterJadwalModal extends StatelessWidget {
  final Dokter dokter;

  const DokterJadwalModal({Key? key, required this.dokter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jadwal dari backend dipisah dengan koma
    final jadwalList = dokter.jadwalPraktek
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(title: 'Jadwal Dokter'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // FOTO DOKTER
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: dokter.fotoProfil != null
                        ? NetworkImage(dokter.fotoProfil!)
                        : null,
                    child: dokter.fotoProfil == null
                        ? const Icon(Icons.person, size: 50, color: Colors.green)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // NAMA DAN KLINIK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dokter",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dokter.namaLengkap,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Klinik",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          dokter.namaPoli,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 4),

                  // LIST JADWAL PRAKTEK
                  if (jadwalList.isNotEmpty)
                    Column(
                      children: jadwalList.map((item) {
                        // Misal format jadwal "Senin 09:00 - 14:00"
                        final parts = item.split(' ');
                        final hari = parts.isNotEmpty ? parts.first : '-';
                        final jam = parts.length > 1
                            ? item.substring(hari.length).trim()
                            : '';

                        return ListTile(
                          leading: const Icon(
                            Icons.verified,
                            color: Colors.green,
                          ),
                          title: Text(
                            hari,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(jam),
                          dense: true,
                          visualDensity:
                              const VisualDensity(vertical: -2, horizontal: -2),
                        );
                      }).toList(),
                    )
                  else
                    const Text(
                      'Tidak ada jadwal tersedia',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
