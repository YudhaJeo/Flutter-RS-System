import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_topbar.dart';
import 'package:intl/intl.dart';
import '../../utils/app_env.dart';

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
      final response = await http.get(
        Uri.parse('${AppEnv.baseUrl}/riwayat_jalan/${widget.id}'),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
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

  String _formatRupiah(dynamic value) {
    if (value == null) return 'Rp 0';
    try {
      final numValue = value is String ? double.parse(value) : value;
      final format = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return format.format(numValue);
    } catch (_) {
      return 'Rp $value';
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
            width: 100,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomTopBar(title: 'Detail Rawat Jalan'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
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
                      error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : data == null
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
                    'Tidak ada data',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.heart_circle_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Detail Rawat Jalan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Kunjungan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            CupertinoIcons.calendar,
                            'Tanggal Rawat',
                            _formatTanggal(data!['TANGGALRAWAT']),
                          ),
                          _buildInfoRow(
                            CupertinoIcons.building_2_fill,
                            'Poli',
                            data!['NAMAPOLI'] ?? '-',
                          ),
                          _buildInfoRow(
                            CupertinoIcons.person_fill,
                            'Pasien',
                            data!['NAMALENGKAP'] ?? '-',
                          ),
                          _buildInfoRow(
                            CupertinoIcons.person_crop_square,
                            'Dokter',
                            data!['NAMADOKTER'] ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluhan & Diagnosa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            CupertinoIcons.exclamationmark_circle,
                            'Keluhan',
                            data!['KELUHAN'] ?? '-',
                          ),
                          _buildInfoRow(
                            CupertinoIcons.doc_text_fill,
                            'Diagnosa',
                            data!['DIAGNOSA'] ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Biaya Card
                  Container(
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian Biaya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            CupertinoIcons.bandage_fill,
                            'Total Tindakan',
                            data!['TOTALTINDAKAN']?.toString() ?? '-',
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Biaya',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                Text(
                                  _formatRupiah(data!['TOTALBIAYA']),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
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