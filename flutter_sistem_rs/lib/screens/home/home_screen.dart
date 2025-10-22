// D:\Mobile App\flutter_sistem_rs\lib\screens\home\home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../reservasi/reservasi_screen.dart';
import '../rekam_medis/rekam_medis_screen.dart';
import '../dompet_medis/dompet_medis_screen.dart';
import '../poli/poli_screen.dart';
import '../kalender/kalender_screen.dart';
import '../daftar_dokter/daftar_dokter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _patientName = 'Pasien';

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _patientName = prefs.getString('namaLengkap') ?? 'Pasien';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar dengan Sapaan dan Ikon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai, $_patientName!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          'Semangat jaga kesehatanmu hari ini!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.bell,
                            color: Colors.blue[800],
                          ),
                          onPressed: () {
                            // Aksi untuk notifikasi
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.chat_bubble_text,
                            color: Colors.blue[800],
                          ),
                          onPressed: () {
                            // Aksi untuk kotak saran
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Search Bar untuk Dokter
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari dokter...',
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Colors.blue[800],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Card Menu Layanan
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: [
                        _buildMenuItem(
                          CupertinoIcons.calendar,
                          'Reservasi',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservasiScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          CupertinoIcons.doc_text,
                          'Rekam Medis',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RekamMedisScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          CupertinoIcons.money_dollar,
                          'Dompet Medis',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DompetMedisScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          CupertinoIcons.building_2_fill,
                          'Poli',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PoliScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          CupertinoIcons.calendar_today,
                          'Kalender',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KalenderScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          CupertinoIcons.person_2_fill,
                          'Daftar Dokter',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaftarDokterScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Card Berita Kesehatan
                Text(
                  'Berita Kesehatan Terkini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200, // Tinggi card berita
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: 3, // Jumlah berita
                    itemBuilder: (context, index) {
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
                                // Gambar berita
                                Image.network(
                                  'https://via.placeholder.com/350x200',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                // Gradient overlay untuk readability teks
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Judul Berita Kesehatan ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Deskripsi singkat berita kesehatan ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Tombol untuk membaca selengkapnya
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // Aksi saat berita diklik
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat item menu
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[800], size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
