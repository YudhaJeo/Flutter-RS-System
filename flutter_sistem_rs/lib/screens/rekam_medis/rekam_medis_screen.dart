import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/rekammedis_model.dart';
import '../../services/rekammedis_service.dart';
import 'detail_rajal_sreen.dart';
import 'detail_ranap_screen.dart';
import '../../widgets/custom_topbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    return "${tgl.day}-${tgl.month}-${tgl.year}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomTopBar(title: 'Rekam Medis'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _riwayat.isEmpty
          ? const Center(child: Text('Belum ada riwayat kunjungan.'))
          : RefreshIndicator(
              onRefresh: _loadRiwayat,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _riwayat.length,
                itemBuilder: (context, i) {
                  final item = _riwayat[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openDetail(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  radius: 24,
                                  child: Icon(
                                    item.jenis == 'RAWAT INAP'
                                        ? Icons.hotel
                                        : Icons.local_hospital,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.jenis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade300, height: 1),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Tanggal',
                              _formatTanggal(item.tanggal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
