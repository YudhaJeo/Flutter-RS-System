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

class _BeritaScreenState extends State<BeritaScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Berita>> _beritaFuture;
  List<Berita> _allBerita = [];
  List<Berita> _filteredBerita = [];
  String _searchQuery = '';

  DateTime? _startDate;
  DateTime? _endDate;

  int _itemsPerPage = 5;
  int _currentPage = 1;
  bool _isDetailMode = false; // 🔹 false = singkat, true = lengkap

  @override
  void initState() {
    super.initState();
    _beritaFuture = BeritaService.fetchAllBerita();
  }

  String formatTanggal(String raw) {
    try {
      final date = DateTime.parse(raw);
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

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.judul.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Berita Terkini',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FutureBuilder<List<Berita>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat berita: ${snapshot.error}',
                  style: const TextStyle(color: Colors.black)),
            );
          }

          if (_allBerita.isEmpty && snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _allBerita = snapshot.data!..sort((a, b) => b.id.compareTo(a.id));
                _filteredBerita = _allBerita;
              });
            });
          }

          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (_currentPage * _itemsPerPage);
          final paginated = _filteredBerita
              .skip(startIndex)
              .take(_itemsPerPage)
              .toList();

          return Column(
            children: [
              // 🔍 Search & Filter
              Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // 🔍 Search
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Cari berita kesehatan...',
                            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: Colors.blue),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 🧭 Filter tanggal
                      IconButton(
                        icon: const Icon(Icons.filter_alt_rounded, color: Colors.blueAccent),
                        tooltip: 'Filter tanggal',
                        onPressed: () => _pickDateRange(context),
                      ),

                      // 🔘 Toggle tampilan (Drive-style)
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: !_isDetailMode ? Colors.blue.shade50 : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.view_agenda_rounded,
                                  color: !_isDetailMode
                                      ? Colors.blueAccent
                                      : Colors.grey.shade500,
                                  size: 22,
                                ),
                                tooltip: 'Detail Singkat',
                                onPressed: () => setState(() => _isDetailMode = false),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: _isDetailMode ? Colors.blue.shade50 : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.article_rounded,
                                  color: _isDetailMode
                                      ? Colors.blueAccent
                                      : Colors.grey.shade500,
                                  size: 22,
                                ),
                                tooltip: 'Detail Lengkap',
                                onPressed: () => setState(() => _isDetailMode = true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // 📄 Daftar Berita
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isDetailMode
                      ? _buildDetailList(paginated)
                      : _buildCompactList(paginated),
                ),
              ),

              // 📄 Pagination
              if (_filteredBerita.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.black54),
                      ),
                      Text(
                        '$_currentPage',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: endIndex < _filteredBerita.length
                            ? () => setState(() => _currentPage++)
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===================== 🔹 MODE RINGKAS =====================
  Widget _buildCompactList(List<Berita> list) {
    return ListView.builder(
      key: const ValueKey('compact'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final berita = list[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                berita.pratinjau,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            title: Text(
              berita.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(formatTanggal(berita.tanggalUpload),
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            onTap: () => _launchURL(berita.url),
          ),
        );
      },
    );
  }

  // ===================== 🔹 MODE DETAIL =====================
  Widget _buildDetailList(List<Berita> list) {
    return ListView.builder(
      key: const ValueKey('detail'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final berita = list[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  berita.pratinjau,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      berita.judul,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      berita.deskripsiSingkat,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        Text(
                          formatTanggal(berita.tanggalUpload),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _launchURL(berita.url),
                        icon: const Icon(Icons.open_in_new,
                            size: 16, color: Colors.blue),
                        label: const Text('Baca Selengkapnya',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
