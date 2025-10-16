import 'package:flutter/material.dart';
import '../../models/reservasi_model.dart';
import '../../services/reservasi_service.dart';
import 'dart:developer' as developer;
import '../reservasi/tambah_reservasi_screen.dart';

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
      // Log tipe data dan nilai
      developer.log('Reservasi ID: ${reservasi.idReservasi}', 
        name: 'ReservasiScreen._batalkanReservasi',
        error: 'Type: ${reservasi.idReservasi.runtimeType}'
      );

      // Pastikan idReservasi dikonversi ke integer
      await _reservasiService.batalkanReservasi(reservasi.idReservasi);
      _fetchReservasi();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservasi berhasil dibatalkan')),
      );
    } catch (e, stackTrace) {
      developer.log('Error membatalkan reservasi', 
        name: 'ReservasiScreen._batalkanReservasi',
        error: e,
        stackTrace: stackTrace
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan reservasi: $e')),
      );
    }
  }

  void _tambahReservasi() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const TambahReservasiScreen()
      )
    );

    // Refresh list jika reservasi berhasil ditambahkan
    if (result == true) {
      _fetchReservasi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi Saya'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahReservasi,
          ),
        ],
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
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        onPressed: reservasi.dapatDiedit
                                            ? () {
                                                // TODO: Implementasi edit reservasi
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Fitur edit akan segera hadir'),
                                                  ),
                                                );
                                              }
                                            : null,
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Batalkan'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
