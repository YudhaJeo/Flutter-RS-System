import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/berita_model.dart';
import '../services/berita_service.dart';
import '../screens/berita/berita_screen.dart';

class BeritaWidget extends StatefulWidget {
  const BeritaWidget({super.key});

  @override
  State<BeritaWidget> createState() => _BeritaWidgetState();
}

class _BeritaWidgetState extends State<BeritaWidget> {
  late Future<List<Berita>> _beritaFuture;
  PageController? _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _beritaFuture = BeritaService.fetchAllBerita();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoScroll(int itemCount) {
    // hentikan timer lama jika ada
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (_pageController == null || !_pageController!.hasClients) return;

      _currentPage++;
      if (_currentPage >= itemCount) {
        _currentPage = 0;
      }

      _pageController!.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Berita>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Gagal memuat berita: ${snapshot.error}');
        }

        final beritaList = snapshot.data ?? [];
        if (beritaList.isEmpty) {
          return const Text('Belum ada berita.');
        }

        // urutkan berita dari terbaru
        beritaList.sort((a, b) => b.id.compareTo(a.id));

        // ambil maksimal 4 berita
        final tampilList =
            beritaList.length > 4 ? beritaList.take(4).toList() : beritaList;

        // total item termasuk "lihat semua"
        final totalItem =
            tampilList.length + (beritaList.length > 4 ? 1 : 0);

        // pastikan pageController diinisialisasi sekali
        _pageController ??= PageController(viewportFraction: 0.9);

        // jalankan auto-scroll setelah frame pertama selesai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController != null && mounted) {
            _startAutoScroll(totalItem);
          }
        });

        return SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalItem,
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              // card terakhir = tombol "Lihat Semua Berita"
              if (beritaList.length > 4 && index == tampilList.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BeritaScreen(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/newspaper-background.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withOpacity(0.5)),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.newspaper,
                                    color: Colors.white, size: 40),
                                SizedBox(height: 10),
                                Text(
                                  'Lihat Semua Berita',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final berita = tampilList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Image.network(
                          berita.pratinjau,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error load image: $error');
                            return const Center(
                              child: Icon(Icons.broken_image),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  berita.judul,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  berita.deskripsiSingkat,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  berita.tanggalUpload,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Buka di Browser?'),
                                    content: const Text(
                                      'Apakah kamu yakin ingin membuka berita ini di browser?',
                                    ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
