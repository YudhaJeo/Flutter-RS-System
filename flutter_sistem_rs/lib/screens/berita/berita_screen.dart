// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\screens\berita\berita_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Berita>> _beritaFuture;
  List<Berita> _allBerita = [];
  List<Berita> _filteredBerita = [];
  String _searchQuery = '';

  // 🔹 Range tanggal
  DateTime? _startDate;
  DateTime? _endDate;

  // 🔹 Pagination
  int _itemsPerPage = 5;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _beritaFuture = BeritaService.fetchAllBerita();
  }

  String formatTanggal(String raw) {
    try {
      final date = DateTime.parse(raw.replaceAll('TIB', 'T'));
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return raw;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka URL: $url');
    }
  }

  void _applyFilters() {
    List<Berita> result = _allBerita;

    // 🔍 Filter berdasarkan judul
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.judul.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 📅 Filter berdasarkan rentang tanggal
    if (_startDate != null && _endDate != null) {
      result = result.where((b) {
        final beritaDate = DateTime.parse(b.tanggalUpload);
        return beritaDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            beritaDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredBerita = result;
      _currentPage = 1;
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua Berita')),
      body: FutureBuilder<List<Berita>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat berita: ${snapshot.error}'));
          }

          if (_allBerita.isEmpty && snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _allBerita = snapshot.data!..sort((a, b) => b.id.compareTo(a.id));
                _filteredBerita = _allBerita;
              });
            });
          }

          // 🔹 Pagination
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (_currentPage * _itemsPerPage);
          final paginated = _filteredBerita
              .skip(startIndex)
              .take(_itemsPerPage)
              .toList();

          return Column(
            children: [
              // 🔍 Search & Filter
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Cari berdasarkan judul...',
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilters();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () => _pickDateRange(context),
                    ),
                  ],
                ),
              ),

              // 🗓️ Tampilkan range filter aktif
              if (_startDate != null && _endDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dari: ${DateFormat('d MMM yyyy').format(_startDate!)} '
                        '– ${DateFormat('d MMM yyyy').format(_endDate!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                          _applyFilters();
                        },
                        child: const Text('Hapus Filter'),
                      ),
                    ],
                  ),
                ),

              // 📜 Daftar berita
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: paginated.length,
                  itemBuilder: (context, index) {
                    final berita = paginated[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            berita.pratinjau,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(
                          berita.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              berita.deskripsiSingkat,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatTanggal(berita.tanggalUpload),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Buka di Browser?'),
                              content: const Text(
                                  'Apakah kamu yakin ingin membuka berita ini di browser?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Buka'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _launchURL(berita.url);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // 🔸 Pagination
              if (_filteredBerita.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text('Halaman $_currentPage'),
                    IconButton(
                      onPressed: endIndex < _filteredBerita.length
                          ? () => setState(() => _currentPage++)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
