import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/dokter_model.dart';
import 'custom_topbar.dart';

class DokterJadwalModal extends StatelessWidget {
  final Dokter dokter;

  const DokterJadwalModal({Key? key, required this.dokter}) : super(key: key);

  // Fungsi untuk mendapatkan ikon sesuai hari (konsisten untuk semua hari)
  IconData _getHariIcon(String hari) {
    return CupertinoIcons.calendar_circle_fill;
  }

  // Fungsi untuk mendapatkan warna sesuai hari (lebih profesional)
  Color _getHariColor(String hari) {
    final hariLower = hari.toLowerCase();
    if (hariLower.contains('senin')) return Colors.blue[700]!;
    if (hariLower.contains('selasa')) return Colors.blue[700]!;
    if (hariLower.contains('rabu')) return Colors.blue[700]!;
    if (hariLower.contains('kamis')) return Colors.blue[700]!;
    if (hariLower.contains('jumat')) return Colors.blue[700]!;
    if (hariLower.contains('sabtu')) return Colors.blue[700]!;
    if (hariLower.contains('minggu')) return Colors.blue[700]!;
    return Colors.blue[700]!;
  }

  @override
  Widget build(BuildContext context) {
    // Jadwal dari backend dipisah dengan koma
    final jadwalList = dokter.jadwalPraktek
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomTopBar(title: 'Jadwal Dokter'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card - Info Dokter
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar Dokter
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: dokter.fotoProfil != null
                          ? NetworkImage(dokter.fotoProfil!)
                          : null,
                      child: dokter.fotoProfil == null
                          ? Icon(
                              CupertinoIcons.person_fill,
                              size: 45,
                              color: Colors.blue[700],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama Dokter
                  Text(
                    dokter.namaLengkap,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge Poli
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.building_2_fill,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dokter.namaPoli,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Jadwal Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar_today,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jadwal Praktik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List Jadwal
                  if (jadwalList.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jadwalList.length,
                      itemBuilder: (context, index) {
                        final item = jadwalList[index];
                        // Misal format jadwal "Senin 09:00 - 14:00"
                        final parts = item.split(' ');
                        final hari = parts.isNotEmpty ? parts.first : '-';
                        final jam = parts.length > 1
                            ? item.substring(hari.length).trim()
                            : '';

                        final hariColor = _getHariColor(hari);
                        final hariIcon = _getHariIcon(hari);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                            border: Border.all(
                              color: hariColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon Hari
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: hariColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    hariIcon,
                                    color: hariColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Info Jadwal
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hari,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.clock,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            jam.isNotEmpty ? jam : 'Waktu tidak tersedia',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark_circle_fill,
                                        size: 14,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.calendar_badge_minus,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada jadwal tersedia',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}