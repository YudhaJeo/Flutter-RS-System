import 'package:flutter/material.dart';
import '../../models/reservasi_model.dart';
import '../../services/reservasi_service.dart';
import 'dart:developer' as developer;
import '../reservasi/tambah_reservasi_screen.dart';
import '../reservasi/edit_reservasi_screen.dart';

class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  final ReservasiService _reservasiService = ReservasiService();
  List<Reservasi> _reservasiList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReservasi();
  }

  Future<void> _fetchReservasi() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final reservasi = await _reservasiService.fetchReservasiByNIK();

      // Urutkan reservasi berdasarkan createdAt dari yang terbaru
      reservasi.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _reservasiList = reservasi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _batalkanReservasi(Reservasi reservasi) async {
    try {
      // Batalkan reservasi
      await _reservasiService.batalkanReservasi(reservasi.idReservasi);

      // Refresh daftar reservasi
      await _fetchReservasi();

      // Tampilkan toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservasi telah dibatalkan')),
        );
      }
    } catch (e, stackTrace) {
      // Log error untuk debugging
      developer.log(
        'Error membatalkan reservasi',
        name: 'ReservasiScreen._batalkanReservasi',
        error: e,
        stackTrace: stackTrace,
      );

      // Cek apakah error terkait dengan masalah tipe atau null
      final errorMessage = e.toString().toLowerCase();
      final isSuccessfullyProcessed =
          errorMessage.contains('type') ||
          errorMessage.contains('null') ||
          errorMessage.contains('subtype');

      // Tampilkan toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSuccessfullyProcessed
                  ? 'Reservasi telah dibatalkan'
                  : 'Gagal membatalkan reservasi: $e',
            ),
          ),
        );
      }

      // Refresh daftar reservasi meskipun ada error
      await _fetchReservasi();
    }
  }

  void _tambahReservasi() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahReservasiScreen()),
    );

    // Refresh list jika reservasi berhasil ditambahkan
    if (result == true) {
      _fetchReservasi();
    }
  }

  void _editReservasi(Reservasi reservasi) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReservasiScreen(reservasi: reservasi),
      ),
    );

    // Refresh list jika reservasi berhasil diubah
    if (result == true) {
      _fetchReservasi();
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Reservasi Saya'),
      backgroundColor: const Color.fromARGB(255, 66, 159, 235),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text('Error: $_errorMessage'))
            : _reservasiList.isEmpty
                ? const Center(child: Text('Tidak ada reservasi'))
                : RefreshIndicator(
                    onRefresh: _fetchReservasi,
                    child: ListView.builder(
                      itemCount: _reservasiList.length,
                      itemBuilder: (context, index) {
                        final reservasi = _reservasiList[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reservasi ${reservasi.idReservasi}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow('Poli', reservasi.namaPoli ?? '-'),
                                _buildInfoRow('Dokter', reservasi.namaDokter ?? '-'),
                                _buildInfoRow('Tanggal', reservasi.tanggalReservasi),
                                _buildInfoRow('Jam', reservasi.jamReservasi ?? '-'),
                                _buildInfoRow('Status', reservasi.status),
                                if (reservasi.keterangan != null)
                                  _buildInfoRow('Keterangan', reservasi.keterangan!),
                                const SizedBox(height: 16),
                               Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      label: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: reservasi.dapatDiedit
                                          ? () => _editReservasi(reservasi)
                                          : null,
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.cancel, color: Colors.white),
                                      label: const Text(
                                        'Batalkan',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: reservasi.dapatDibatalkan
                                          ? () => _batalkanReservasi(reservasi)
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
    floatingActionButton: FloatingActionButton(
      onPressed: _tambahReservasi,
      backgroundColor: Color.fromARGB(255, 66, 159, 235),
      child: const Icon(Icons.add, size: 32),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

  // Method untuk memformat tanggal
  String _formatTanggal(String tanggalString) {
    try {
      // Parse tanggal dari string, pastikan menggunakan UTC
      final tanggalUtc = DateTime.parse(tanggalString);
      final tanggal = tanggalUtc.toLocal();

      // Log untuk debugging
      developer.log(
        'Konversi Tanggal',
        name: 'ReservasiScreen._formatTanggal',
        error: {'Input': tanggalString, 'UTC': tanggalUtc, 'Lokal': tanggal},
      );

      // Daftar nama bulan dalam bahasa Indonesia
      final bulan = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      // Daftar nama hari dalam bahasa Indonesia
      final hari = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];

      // Format: "Senin, 20 Maret 2024"
      return '${hari[tanggal.weekday - 1]}, ${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
    } catch (e) {
      // Jika parsing gagal, kembalikan tanggal asli
      return tanggalString;
    }
  }

  // Modifikasi method _buildInfoRow untuk menggunakan format tanggal baru
  Widget _buildInfoRow(String label, String value) {
    // Jika label adalah 'Tanggal', gunakan method _formatTanggal
    final formattedValue = label == 'Tanggal' ? _formatTanggal(value) : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(formattedValue),
        ],
      ),
    );
  }
}
