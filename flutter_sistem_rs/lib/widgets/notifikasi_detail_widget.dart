
// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\widgets\notifikasi_detail_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notifikasi_model.dart';

class NotifikasiDetailModal extends StatelessWidget {
  final Notifikasi notifikasi;

  const NotifikasiDetailModal({super.key, required this.notifikasi});

  String _formatTanggal(DateTime? tanggal) {
    if (tanggal == null) return '-';
    final localTime = tanggal.toLocal();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(localTime);
  }

  String _formatWaktu(DateTime? tanggal) {
    if (tanggal == null) return '-';
    final localTime = tanggal.toLocal();
    return DateFormat('HH:mm', 'id_ID').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: Colors.blue.shade700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifikasi.judul,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: notifikasi.status
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: notifikasi.status
                                        ? Colors.green.shade200
                                        : Colors.orange.shade200,
                                  ),
                                ),
                                child: Text(
                                  notifikasi.status
                                      ? 'Sudah dibaca'
                                      : 'Belum dibaca',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: notifikasi.status
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider
                    Divider(color: Colors.grey.shade200, height: 1),
                    
                    const SizedBox(height: 24),
                    
                    // Pesan
                    const Text(
                      'Pesan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notifikasi.pesan,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Informasi Reservasi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Informasi Reservasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Tanggal',
                            value: _formatTanggal(notifikasi.tanggalReservasi),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.access_time,
                            label: 'Waktu',
                            value: _formatWaktu(notifikasi.tanggalReservasi),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.local_hospital,
                            label: 'Poli',
                            value: notifikasi.namaPoli ?? '-',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Dokter',
                            value: notifikasi.namaDokter ?? '-',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tombol Tutup
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}