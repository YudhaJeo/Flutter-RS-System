import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/rekammedis_model.dart';
import '../../services/rekammedis_service.dart';
import 'detail_rajal_sreen.dart';
import 'detail_ranap_screen.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID riwayat tidak ditemukan')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kunjungan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _riwayat.isEmpty
                  ? const Center(child: Text('Belum ada riwayat kunjungan.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _riwayat.length,
                      itemBuilder: (context, i) {
                        final item = _riwayat[i];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              item.jenis == 'RAWAT INAP'
                                  ? Icons.hotel
                                  : Icons.local_hospital,
                              color: Colors.blue,
                            ),
                            title: Text(item.jenis),
                            subtitle: Text('Tanggal: ${_formatTanggal(item.tanggal)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () => _openDetail(item),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}