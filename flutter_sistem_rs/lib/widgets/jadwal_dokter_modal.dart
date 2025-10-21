// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\widgets\dokter_jadwal_modal.dart
import 'package:flutter/material.dart';
import '../models/dokter_model.dart';

class DokterJadwalModal extends StatelessWidget {
  final Dokter dokter;

  const DokterJadwalModal({Key? key, required this.dokter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pisahkan jadwal per baris berdasarkan koma
    final jadwalList = dokter.jadwalPraktek
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                dokter.namaLengkap,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jadwal Praktek:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (jadwalList.isNotEmpty)
              ...jadwalList.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• $item',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
            else
              const Text(
                'Tidak ada jadwal tersedia',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
