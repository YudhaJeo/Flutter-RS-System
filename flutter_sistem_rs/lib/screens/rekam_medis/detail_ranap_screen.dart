import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


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
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  Widget _buildSection(String title, List<dynamic>? items, List<String> keys) {
    if (items == null || items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('$title: Tidak ada data'),
      );
    }

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: items.map((item) {
        return ListTile(
          title: Text(item[keys[0]] ?? '-'),
          subtitle: Text('${keys[1]}: ${item[keys[1]] ?? '-'}'),
          trailing: Text(formatRupiah(item['TOTAL'] ?? 0)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Rawat Inap')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : data == null
                  ? const Center(child: Text('Tidak ada data'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasien: ${data!['NAMALENGKAP'] ?? '-'}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Nomor Bed: ${data!['NOMORBED'] ?? '-'}'),
                          Text('Tanggal Masuk: ${formatTanggal(data!['TANGGALMASUK'])}'),
                          Text('Tanggal Keluar: ${formatTanggal(data!['TANGGALKELUAR'])}'),
                          const Divider(height: 24),

                          Text('Total Kamar: ${formatRupiah(data!['TOTALKAMAR'])}'),
                          Text('Total Obat: ${formatRupiah(data!['TOTALOBAT'])}'),
                          Text('Total Tindakan: ${formatRupiah(data!['TOTALTINDAKAN'])}'),
                          Text('Total Alkes: ${formatRupiah(data!['TOTALALKES'])}'),
                          const SizedBox(height: 8),
                          Text(
                            'Total Biaya: ${formatRupiah(data!['TOTALBIAYA'])}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 24),

                          _buildSection(
                            'Daftar Obat',
                            data!['obat'],
                            ['NAMAOBAT', 'JENISOBAT'],
                          ),

                          _buildSection(
                            'Daftar Alkes',
                            data!['alkes'],
                            ['NAMAALKES', 'JENISALKES'],
                          ),

                          _buildSection(
                            'Daftar Tindakan',
                            data!['tindakan'],
                            ['NAMATINDAKAN', 'KATEGORI'],
                          ),
                        ],
                      ),
                    ),
    );
  }
}
