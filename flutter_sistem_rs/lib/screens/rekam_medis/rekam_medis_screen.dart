import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/rekammedis_model.dart';
import '../../services/rekammedis_service.dart';
import 'detail_rajal_sreen.dart';
import 'detail_ranap_screen.dart';
import '../../widgets/custom_topbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/loading_widget.dart';

class RekamMedisScreen extends StatefulWidget {
  const RekamMedisScreen({super.key});

  @override
  State<RekamMedisScreen> createState() => _RekamMedisScreenState();
}

class _RekamMedisScreenState extends State<RekamMedisScreen> {
  final RekamMedisService _service = RekamMedisService();
  List<RekamMedis> _riwayat = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final nik = prefs.getString('nik') ?? prefs.getString('NIK');

      if (nik == null || nik.isEmpty) {
        setState(() {
          _error = 'NIK tidak ditemukan. Silakan login ulang.';
          _loading = false;
        });
        return;
      }

      final data = await _service.fetchDetailRekamMedis(nik);
      setState(() {
        _riwayat = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatTanggal(String tanggal) {
    if (tanggal.isEmpty) return '-';
    final tgl = DateTime.tryParse(tanggal);
    if (tgl == null) return tanggal;
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tgl);
    } catch (e) {
      return "${tgl.day}-${tgl.month}-${tgl.year}";
    }
  }

  void _openDetail(RekamMedis item) {
    if (item.jenis == 'RAWAT JALAN' && item.idRawatJalan != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailRawatJalanScreen(id: item.idRawatJalan!),
        ),
      );
    } else if (item.jenis == 'RAWAT INAP' && item.idRawatInap != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailRawatInapScreen(id: item.idRawatInap!),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'ID Riwayat tidak ditemukan.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  int _getRawatJalanCount() {
    return _riwayat.where((item) => item.jenis == 'RAWAT JALAN').length;
  }

  int _getRawatInapCount() {
    return _riwayat.where((item) => item.jenis == 'RAWAT INAP').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomTopBar(title: 'Rekam Medis'),
      body: _loading
          ? const LoadingWidget(message: 'Memuat riwayat medis...')
          : _error != null
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
                      _error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : _riwayat.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat kunjungan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRiwayat,
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
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
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
                                CupertinoIcons.doc_text_fill,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Riwayat Kunjungan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_riwayat.length} Kunjungan',
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
                                    CupertinoIcons.building_2_fill,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_getRawatJalanCount()} Rawat Jalan',
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
                                    CupertinoIcons.bed_double_fill,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_getRawatInapCount()} Rawat Inap',
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

                  // List Riwayat
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _riwayat.length,
                      itemBuilder: (context, i) {
                        final item = _riwayat[i];
                        final isRawatInap = item.jenis == 'RAWAT INAP';

                        return GestureDetector(
                          onTap: () => _openDetail(item),
                          child: Container(
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
                                color: isRawatInap
                                    ? Colors.purple.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isRawatInap
                                            ? [
                                                Colors.purple[100]!,
                                                Colors.purple[50]!,
                                              ]
                                            : [
                                                Colors.blue[100]!,
                                                Colors.blue[50]!,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isRawatInap
                                            ? Colors.purple.withOpacity(0.2)
                                            : Colors.blue.withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      isRawatInap
                                          ? CupertinoIcons.bed_double_fill
                                          : CupertinoIcons.building_2_fill,
                                      color: isRawatInap
                                          ? Colors.purple[700]
                                          : Colors.blue[700],
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.jenis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                _formatTanggal(item.tanggal),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isRawatInap
                                                ? Colors.purple[50]
                                                : Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                CupertinoIcons.eye_fill,
                                                size: 12,
                                                color: isRawatInap
                                                    ? Colors.purple[700]
                                                    : Colors.blue[700],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Lihat Detail',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isRawatInap
                                                      ? Colors.purple[700]
                                                      : Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow Icon
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
