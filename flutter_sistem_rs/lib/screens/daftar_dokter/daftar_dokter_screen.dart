import 'package:flutter/material.dart';
import '../../models/dokter_model.dart';
import '../../services/dokter_service.dart';
import '../../widgets/jadwal_dokter_modal.dart';
import '../../widgets/custom_topbar.dart';

class DaftarDokterScreen extends StatefulWidget {
  const DaftarDokterScreen({super.key});

  @override
  State<DaftarDokterScreen> createState() => _DaftarDokterScreenState();
}

class _DaftarDokterScreenState extends State<DaftarDokterScreen> {
  late Future<List<Dokter>> futureDokter;
  List<Dokter> allDokter = [];
  List<Dokter> filteredDokter = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureDokter = _fetchData();
    _searchController.addListener(_filterDokter);
  }

  Future<List<Dokter>> _fetchData() async {
    final dokterList = await DokterService.fetchAllDokter();
    dokterList.sort(
      (a, b) => a.namaLengkap.toLowerCase().compareTo(b.namaLengkap.toLowerCase()),
    );

    setState(() {
      allDokter = dokterList;
      filteredDokter = dokterList;
    });

    return dokterList;
  }

  void _filterDokter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDokter = allDokter.where((dokter) {
        return dokter.namaLengkap.toLowerCase().contains(query) ||
               dokter.namaPoli.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _openJadwalDokter(Dokter dokter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterJadwalModal(dokter: dokter),
      ),
    );
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
      appBar: const CustomTopBar(title: 'Cari Dokter'),
      body: FutureBuilder<List<Dokter>>(
        future: futureDokter,
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
            return const Center(child: Text('Belum ada data dokter.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureDokter = _fetchData();
              });
            },
            child: Column(
              children: [
                // 🔍 SearchBar di atas daftar dokter
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama dokter atau poli...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // 📋 Daftar Dokter
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredDokter.length,
                    itemBuilder: (context, index) {
                      final dokter = filteredDokter[index];
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
                          onTap: () => _openJadwalDokter(dokter),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.blue.shade50,
                                  backgroundImage: dokter.fotoProfil != null
                                      ? NetworkImage(dokter.fotoProfil!)
                                      : null,
                                  child: dokter.fotoProfil == null
                                      ? const Icon(Icons.person,
                                          color: Colors.blue, size: 35)
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  dokter.namaLengkap.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dokter.namaPoli,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(color: Colors.grey.shade300, height: 1),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () => _openJadwalDokter(dokter),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'LIHAT JADWAL',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
          );
        },
      ),
    );
  }
}