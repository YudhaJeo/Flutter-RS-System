import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_topbar.dart';
import 'package:intl/intl.dart';

class DetailRawatJalanScreen extends StatefulWidget {
  final int id;
  const DetailRawatJalanScreen({super.key, required this.id});

  @override
  State<DetailRawatJalanScreen> createState() => _DetailRawatJalanScreenState();
}

class _DetailRawatJalanScreenState extends State<DetailRawatJalanScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:4100/riwayat_jalan/${widget.id}'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        setState(() {
          data = body['data'];
          loading = false;
        });
      } else {
        setState(() {
          error = 'Gagal mengambil detail rawat jalan';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final parsed = DateTime.parse(tanggal);
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return tanggal;
    }
  }

  Widget _buildInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(title: 'Detail Rawat Jalan'),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : data == null
                  ? const Center(child: Text('Tidak ada data'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.local_hospital,
                                    color: Colors.blue.shade700, size: 60),
                                const SizedBox(height: 10),
                                Text(
                                  'Detail Rawat Jalan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                          _buildInfo(Icons.calendar_today, 'Tanggal Rawat',
                              _formatTanggal(data!['TANGGALRAWAT'])),
                          _buildInfo(Icons.medical_services, 'Poli',
                              data!['NAMAPOLI'] ?? '-'),
                          _buildInfo(Icons.person, 'Pasien',
                              data!['NAMALENGKAP'] ?? '-'),
                          _buildInfo(Icons.warning_amber, 'Keluhan',
                              data!['KELUHAN'] ?? '-'),
                          _buildInfo(Icons.assignment, 'Diagnosa',
                              data!['DIAGNOSA'] ?? '-'),
                          _buildInfo(Icons.list_alt, 'Total Tindakan',
                              data!['TOTALTINDAKAN']?.toString() ?? '-'),
                          const Divider(height: 32, thickness: 1),
                          _buildInfo(Icons.payments, 'Total Biaya',
                              'Rp ${data!['TOTALBIAYA'] ?? '-'}'),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text(
                                'Kembali',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}