import 'package:flutter/material.dart';
import '../../models/poli_model.dart';
import '../../services/poli_service.dart';
import '../../services/dokter_service.dart';
import 'dokter_by_poli_screen.dart';
import '../../widgets/custom_topbar.dart';

class PoliScreen extends StatefulWidget {
  const PoliScreen({Key? key}) : super(key: key);

  @override
  State<PoliScreen> createState() => _PoliScreenState();
}

class _PoliScreenState extends State<PoliScreen> {
  late Future<List<Poli>> futurePoli;
  List<Poli> allPoli = [];
  List<Poli> filteredPoli = [];
  Map<int, int> jumlahDokterPerPoli = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futurePoli = _fetchData();
    _searchController.addListener(_filterPoli);
  }

  Future<List<Poli>> _fetchData() async {
    final poliList = await PoliService.fetchPoli();
    poliList.sort((a, b) => a.namaPoli.compareTo(b.namaPoli));

    for (var poli in poliList) {
      final dokterList = await DokterService.fetchDokterByPoli(poli.idPoli);
      jumlahDokterPerPoli[poli.idPoli] = dokterList.length;
    }

    setState(() {
      allPoli = poliList;
      filteredPoli = poliList;
    });

    return poliList;
  }

  void _filterPoli() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPoli = allPoli
          .where((poli) => poli.namaPoli.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomTopBar(title: 'Daftar Poli'),
      body: FutureBuilder<List<Poli>>(
        future: futurePoli,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data poli.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futurePoli = _fetchData();
              });
            },
            child: Column(
              children: [
                // 🔍 Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari poli...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // 📋 List Poli
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: filteredPoli.length,
                    itemBuilder: (context, index) {
                      final poli = filteredPoli[index];
                      final jumlah = jumlahDokterPerPoli[poli.idPoli] ?? 0;

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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DokterByPoliScreen(
                                  idPoli: poli.idPoli,
                                  namaPoli: poli.namaPoli,
                                ),
                              ),
                            );
                          },
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
                                      child: const Icon(
                                        Icons.local_hospital,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        poli.namaPoli,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(color: Colors.grey.shade300, height: 1),
                                const SizedBox(height: 10),
                                _buildInfoRow('Jumlah Dokter', '$jumlah orang'),
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
          );
        },
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
