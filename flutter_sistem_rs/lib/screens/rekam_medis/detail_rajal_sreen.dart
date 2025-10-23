import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Rawat Jalan')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : data == null
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView(
  padding: const EdgeInsets.all(16),
  children: [
    Text(
      'Tanggal Rawat: ${data!['TANGGALRAWAT'] ?? '-'}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    Text('Poli: ${data!['NAMAPOLI'] ?? '-'}'),
    Text('Pasien: ${data!['NAMALENGKAP'] ?? '-'}'),
    Text('Keluhan: ${data!['KELUHAN'] ?? '-'}'),
    Text('Diagnosa: ${data!['DIAGNOSA'] ?? '-'}'),
    Text('Total Tindakan: ${data!['TOTALTINDAKAN'] ?? '-'}'),
    Text('Total Biaya: Rp ${data!['TOTALBIAYA'] ?? '-'}'),
  ],
),
    );
  }
}
