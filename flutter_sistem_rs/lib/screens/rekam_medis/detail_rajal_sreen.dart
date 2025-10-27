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
      final res = await http.get(
        Uri.parse('http://10.0.2.2:4100/riwayat_jalan/${widget.id}'),
      );
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomTopBar(title: 'Detail Rawat Jalan'),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
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
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Icon(Icons.local_hospital_rounded,
                                      color: Colors.blue.shade700, size: 48),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Detail Rawat Jalan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfo(Icons.calendar_today_rounded,
                                      'Tanggal Rawat',
                                      _formatTanggal(data!['TANGGALRAWAT'])),
                                  _buildInfo(Icons.medical_services_rounded,
                                      'Poli', data!['NAMAPOLI'] ?? '-'),
                                  _buildInfo(Icons.person_rounded, 'Pasien',
                                      data!['NAMALENGKAP'] ?? '-'),
                                  _buildInfo(Icons.warning_amber_rounded,
                                      'Keluhan', data!['KELUHAN'] ?? '-'),
                                  _buildInfo(Icons.assignment_rounded,
                                      'Diagnosa', data!['DIAGNOSA'] ?? '-'),
                                  _buildInfo(Icons.list_alt_rounded,
                                      'Total Tindakan',
                                      data!['TOTALTINDAKAN']?.toString() ??
                                          '-'),
                                  const SizedBox(height: 10),
                                  const Divider(thickness: 1),
                                  const SizedBox(height: 10),
                                  _buildInfo(Icons.payments_rounded,
                                      'Total Biaya',
                                      'Rp ${data!['TOTALBIAYA'] ?? '-'}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}