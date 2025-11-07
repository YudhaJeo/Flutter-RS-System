import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_topbar.dart';

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
  DateTime? _startDate;
  DateTime? _endDate;
  int _itemsPerPage = 5;
  int _currentPage = 1;
  bool _isDetailMode = false;

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
          .where((b) => b.judul.toLowerCase().contains(_searchQuery.toLowerCase()))
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
      _filteredBerita = _allBerita;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<Berita>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat berita kesehatan...');
          }
          
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
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
          final paginated = _filteredBerita.skip(startIndex).take(_itemsPerPage).toList();

          return Column(
            children: [
              const CustomTopBar(title: 'Berita Kesehatan'),
              _buildSearchAndFilter(),
              if (_startDate != null || _endDate != null) _buildActiveFilters(),
              Expanded(
                child: _filteredBerita.isEmpty
                    ? _buildEmptyState()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isDetailMode
                            ? _buildDetailList(paginated)
                            : _buildCompactList(paginated),
                      ),
              ),
              if (_filteredBerita.isNotEmpty) _buildPagination(endIndex),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade600, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(),
          const SizedBox(width: 8),
          _buildViewModeToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    final hasFilter = _startDate != null || _endDate != null;
    return Container(
      decoration: BoxDecoration(
        color: hasFilter ? Colors.blue.shade600 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.filter_alt_outlined,
          color: hasFilter ? Colors.white : Colors.blue.shade600,
          size: 24,
        ),
        onPressed: () => _pickDateRange(context),
        tooltip: 'Filter tanggal',
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.view_agenda_outlined,
            isActive: !_isDetailMode,
            onTap: () => setState(() => _isDetailMode = false),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade200),
          _buildToggleButton(
            icon: Icons.article_outlined,
            isActive: _isDetailMode,
            onTap: () => setState(() => _isDetailMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isActive ? Colors.blue.shade600 : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filter: ${formatTanggal(_startDate.toString())} - ${formatTanggal(_endDate.toString())}',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: _clearFilters,
            child: Icon(Icons.close, color: Colors.blue.shade700, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactList(List<Berita> list) {
    return ListView.builder(
      key: const ValueKey('compact'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final berita = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _launchURL(berita.url),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      berita.pratinjau,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          berita.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 13, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              formatTanggal(berita.tanggalUpload),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailList(List<Berita> list) {
    return ListView.builder(
      key: const ValueKey('detail'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final berita = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  berita.pratinjau,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      berita.judul,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      berita.deskripsiSingkat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Colors.blue.shade700),
                              const SizedBox(width: 6),
                              Text(
                                formatTanggal(berita.tanggalUpload),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _launchURL(berita.url),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.blue.shade400],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Baca',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPagination(int endIndex) {
    final totalPages = (_filteredBerita.length / _itemsPerPage).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.arrow_back_ios,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$_currentPage / $totalPages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildPaginationButton(
            icon: Icons.arrow_forward_ios,
            enabled: endIndex < _filteredBerita.length,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey.shade400,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada berita ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah kata kunci atau filter pencarian',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}