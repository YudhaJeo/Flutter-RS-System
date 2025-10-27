import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../widgets/custom_topbar.dart';

class DetailRawatInapScreen extends StatefulWidget {
  final int id;
  const DetailRawatInapScreen({super.key, required this.id});

  @override
  State<DetailRawatInapScreen> createState() => _DetailRawatInapScreenState();
}

class _DetailRawatInapScreenState extends State<DetailRawatInapScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      fetchDetail();
    });
  }

  Future<void> fetchDetail() async {
    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:4100/riwayat_inap/${widget.id}'),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        setState(() {
          data = body['data'];
          loading = false;
        });
      } else {
        setState(() {
          error = 'Gagal mengambil detail rawat inap';
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

  String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    final parsed = DateTime.tryParse(tanggal);
    if (parsed == null) return '-';
    return DateFormat("d MMMM y", "id_ID").format(parsed);
  }

  String formatRupiah(num? value) {
    if (value == null) return "Rp 0";
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic>? items,
      {String? label1, String? label2}) {
    if (items == null || items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '$title: Tidak ada data',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ExpansionTile(
      iconColor: Colors.blue.shade700,
      collapsedIconColor: Colors.grey,
      tilePadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blue.shade700,
        ),
      ),
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item[label1 ?? ''] ?? '-',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(
                      '${label2 ?? ''}: ${item[label2 ?? ''] ?? '-'}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(item['TOTAL'] ?? 0),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(title: 'Detail Rawat Inap'),
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
                                Icon(Icons.hotel,
                                    color: Colors.blue.shade700, size: 55),
                                const SizedBox(height: 10),
                                Text(
                                  'Detail Rawat Inap',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          _buildInfoRow(Icons.person, 'Pasien',
                              data!['NAMALENGKAP'] ?? '-'),
                          _buildInfoRow(Icons.bed, 'Nomor Bed',
                              data!['NOMORBED'] ?? '-'),
                          _buildInfoRow(Icons.login, 'Tanggal Masuk',
                              formatTanggal(data!['TANGGALMASUK'])),
                          _buildInfoRow(Icons.logout, 'Tanggal Keluar',
                              formatTanggal(data!['TANGGALKELUAR'])),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.meeting_room, 'Total Kamar',
                              formatRupiah(data!['TOTALKAMAR'])),
                          _buildInfoRow(Icons.medical_services, 'Total Obat',
                              formatRupiah(data!['TOTALOBAT'])),
                          _buildInfoRow(Icons.healing, 'Total Alkes',
                              formatRupiah(data!['TOTALALKES'])),
                          _buildInfoRow(Icons.content_paste, 'Total Tindakan',
                              formatRupiah(data!['TOTALTINDAKAN'])),
                          const SizedBox(height: 10),
                          const Divider(height: 24),
                          Text(
                            'Total Biaya: ${formatRupiah(data!['TOTALBIAYA'])}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSection('Daftar Obat', data!['obat'],
                              label1: 'NAMAOBAT', label2: 'JENISOBAT'),
                          _buildSection('Daftar Alkes', data!['alkes'],
                              label1: 'NAMAALKES', label2: 'JENISALKES'),
                          _buildSection('Daftar Tindakan', data!['tindakan'],
                              label1: 'NAMATINDAKAN', label2: 'KATEGORI'),
                          const SizedBox(height: 30),
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