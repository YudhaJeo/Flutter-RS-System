import 'package:flutter/material.dart';
import '../../models/reservasi_model.dart';
import '../../services/reservasi_service.dart';
import 'dart:developer' as developer;
import '../reservasi/tambah_reservasi_screen.dart';
import '../reservasi/edit_reservasi_screen.dart';
import '../../widgets/custom_topbar.dart';

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
      backgroundColor: Colors.white,
      appBar: CustomTopBar(title: 'Reservasi Saya'),
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
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reservasi ${_formatTanggalPendek(reservasi.tanggalReservasi)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (reservasi.status.toLowerCase() ==
                                              'selesai' ||
                                          reservasi.status.toLowerCase() ==
                                              'dikonfirmasi')
                                      ? Colors.green.shade100
                                      : reservasi.status.toLowerCase() ==
                                            'dibatalkan'
                                      ? Colors.red.shade100
                                      : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reservasi.status,
                                  style: TextStyle(
                                    color:
                                        (reservasi.status.toLowerCase() ==
                                                'selesai' ||
                                            reservasi.status.toLowerCase() ==
                                                'dikonfirmasi')
                                        ? Colors.green.shade800
                                        : reservasi.status.toLowerCase() ==
                                              'dibatalkan'
                                        ? Colors.red.shade800
                                        : Colors.blue.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(color: Colors.grey.shade300, height: 1),
                          const SizedBox(height: 10),
                          _buildInfoRow('Poli', reservasi.namaPoli ?? '-'),
                          _buildInfoRow('Dokter', reservasi.namaDokter ?? '-'),
                          _buildInfoRow('Tanggal', reservasi.tanggalReservasi),
                          _buildInfoRow('Jam', reservasi.jamReservasi ?? '-'),
                          if (reservasi.keterangan != null)
                            _buildInfoRow('Keterangan', reservasi.keterangan!),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                icon: Icon(
                                  Icons.edit,
                                  color: reservasi.dapatDiedit
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                                label: Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: reservasi.dapatDiedit
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: reservasi.dapatDiedit
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: reservasi.dapatDiedit
                                    ? () => _editReservasi(reservasi)
                                    : null,
                              ),
                              OutlinedButton.icon(
                                icon: Icon(
                                  Icons.cancel,
                                  color: reservasi.dapatDibatalkan
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                label: Text(
                                  'Batalkan',
                                  style: TextStyle(
                                    color: reservasi.dapatDibatalkan
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: reservasi.dapatDibatalkan
                                        ? Colors.red.shade300
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // bayangan halus
              spreadRadius: 2,
              blurRadius: 12, // blur lembut
              offset: const Offset(0, 4), // arah bayangan ke bawah
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _tambahReservasi,
          backgroundColor: Colors.white,
          elevation: 3, // hilangkan default shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, size: 36, color: Colors.lightBlue),
        ),
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

  String _formatTanggalPendek(String tanggalString) {
    try {
      final tanggal = DateTime.parse(tanggalString).toLocal();
      final dd = tanggal.day.toString().padLeft(2, '0');
      final mm = tanggal.month.toString().padLeft(2, '0');
      final yyyy = tanggal.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (e) {
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
