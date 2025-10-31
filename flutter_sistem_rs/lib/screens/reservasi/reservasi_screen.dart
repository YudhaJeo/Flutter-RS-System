import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/reservasi_model.dart';
import '../../services/reservasi_service.dart';
import 'dart:developer' as developer;
import '../reservasi/tambah_reservasi_screen.dart';
import '../reservasi/edit_reservasi_screen.dart';
import '../../widgets/custom_topbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Reservasi'),
        content: const Text('Apakah Anda yakin ingin membatalkan reservasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reservasiService.batalkanReservasi(reservasi.idReservasi);
      await _fetchReservasi();

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Reservasi telah dibatalkan.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[700],
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error membatalkan reservasi',
        name: 'ReservasiScreen._batalkanReservasi',
        error: e,
        stackTrace: stackTrace,
      );

      final errorMessage = e.toString().toLowerCase();
      final isSuccessfullyProcessed =
          errorMessage.contains('type') ||
          errorMessage.contains('null') ||
          errorMessage.contains('subtype');

      Fluttertoast.showToast(
        msg: isSuccessfullyProcessed
            ? '✅ Reservasi telah dibatalkan'
            : '❌ Gagal membatalkan reservasi: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: isSuccessfullyProcessed
            ? Colors.green.shade600
            : Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 15,
      );

      await _fetchReservasi();
    }
  }

  void _tambahReservasi() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahReservasiScreen()),
    );

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

    if (result == true) {
      _fetchReservasi();
    }
  }

  int _getAktifCount() {
    return _reservasiList.where((r) => 
      r.status.toLowerCase() != 'dibatalkan' && 
      r.status.toLowerCase() != 'selesai'
    ).length;
  }

  int _getSelesaiCount() {
    return _reservasiList.where((r) => 
      r.status.toLowerCase() == 'selesai' || 
      r.status.toLowerCase() == 'dikonfirmasi'
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomTopBar(title: 'Reservasi Saya'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : _reservasiList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.calendar_badge_plus,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada reservasi',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk membuat reservasi',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchReservasi,
              child: Column(
                children: [
                  // Summary Card
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                CupertinoIcons.calendar_badge_plus,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Total Reservasi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_reservasiList.length} Reservasi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.clock_fill,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_getAktifCount()} Aktif',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.check_mark_circled_solid,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_getSelesaiCount()} Selesai',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // List Reservasi
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: _reservasiList.length,
                      itemBuilder: (context, index) {
                        final reservasi = _reservasiList[index];
                        final isSelesai = reservasi.status.toLowerCase() == 'selesai' ||
                            reservasi.status.toLowerCase() == 'dikonfirmasi';
                        final isDibatalkan = reservasi.status.toLowerCase() == 'dibatalkan';
                        
                        Color statusColor;
                        Color statusColorLight;
                        Color statusColorDark;
                        
                        if (isSelesai) {
                          statusColor = Colors.green;
                          statusColorLight = Colors.green[50]!;
                          statusColorDark = Colors.green[700]!;
                        } else if (isDibatalkan) {
                          statusColor = Colors.red;
                          statusColorLight = Colors.red[50]!;
                          statusColorDark = Colors.red[700]!;
                        } else {
                          statusColor = Colors.blue;
                          statusColorLight = Colors.blue[50]!;
                          statusColorDark = Colors.blue[700]!;
                        }

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
                              color: statusColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Reservasi ${_formatTanggalPendek(reservasi.tanggalReservasi)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColorLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSelesai
                                                ? CupertinoIcons.check_mark_circled_solid
                                                : isDibatalkan
                                                ? CupertinoIcons.xmark_circle_fill
                                                : CupertinoIcons.clock_fill,
                                            size: 14,
                                            color: statusColorDark,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            reservasi.status,
                                            style: TextStyle(
                                              color: statusColorDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(color: Colors.grey.shade200, height: 1),
                                const SizedBox(height: 12),
                                
                                // Info Detail
                                _buildInfoRow(
                                  CupertinoIcons.building_2_fill,
                                  'Poli',
                                  reservasi.namaPoli ?? '-',
                                ),
                                _buildInfoRow(
                                  CupertinoIcons.person_fill,
                                  'Dokter',
                                  reservasi.namaDokter ?? '-',
                                ),
                                _buildInfoRow(
                                  CupertinoIcons.calendar,
                                  'Tanggal',
                                  _formatTanggal(reservasi.tanggalReservasi),
                                ),
                                _buildInfoRow(
                                  CupertinoIcons.clock,
                                  'Jam',
                                  reservasi.jamReservasi ?? '-',
                                ),
                                if (reservasi.keterangan != null &&
                                    reservasi.keterangan!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          CupertinoIcons.chat_bubble_text_fill,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Keterangan',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                reservasi.keterangan!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                
                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: Icon(
                                          CupertinoIcons.pencil,
                                          size: 18,
                                          color: reservasi.dapatDiedit
                                              ? Colors.orange[700]
                                              : Colors.grey,
                                        ),
                                        label: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: reservasi.dapatDiedit
                                                ? Colors.orange[700]
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          side: BorderSide(
                                            color: reservasi.dapatDiedit
                                                ? Colors.orange.withOpacity(0.3)
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
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: Icon(
                                          CupertinoIcons.xmark_circle,
                                          size: 18,
                                          color: reservasi.dapatDibatalkan
                                              ? Colors.red[700]
                                              : Colors.grey,
                                        ),
                                        label: Text(
                                          'Batalkan',
                                          style: TextStyle(
                                            color: reservasi.dapatDibatalkan
                                                ? Colors.red[700]
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          side: BorderSide(
                                            color: reservasi.dapatDibatalkan
                                                ? Colors.red.withOpacity(0.3)
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
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahReservasi,
        backgroundColor: Colors.blue[700],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          CupertinoIcons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _formatTanggal(String tanggalString) {
    try {
      final tanggalUtc = DateTime.parse(tanggalString);
      final tanggal = tanggalUtc.toLocal();

      final bulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];

      final hari = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
      ];

      return '${hari[tanggal.weekday - 1]}, ${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
    } catch (e) {
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}