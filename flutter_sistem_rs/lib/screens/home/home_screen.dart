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
import '../kritik_saran/kritik_saran_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../tentang_kami/profileTentang_screen.dart'; // <--- Tambahkan ini
import '../../widgets/berita_widget.dart';
import '../../widgets/home_widget.dart';
import '../../services/notifikasi_service.dart';
import '../../services/reservasi_service.dart';
import '../../services/rekammedis_service.dart';
import '../../services/dompet_medis_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _patientName = 'Pasien';
  String _nik = '';
  bool _hasUnreadNotifications = false;
  int _jumlahReservasi = 0;
  int _jumlahRekamMedis = 0;
  double _totalSaldo = 0;
  bool _isLoadingStats = true;

  final NotifikasiService _notifikasiService = NotifikasiService();
  final ReservasiService _reservasiService = ReservasiService();
  final RekamMedisService _rekamMedisService = RekamMedisService();

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _patientName = prefs.getString('namaLengkap') ?? 'Pasien';
      _nik = prefs.getString('nik') ?? prefs.getString('NIK') ?? '';
    });

    await _loadStatisticsData();
  }

  Future<void> _loadStatisticsData() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      await Future.wait([
        _checkUnreadNotifications(),
        _loadJumlahReservasi(),
        _loadJumlahRekamMedis(),
        _loadTotalSaldo(),
      ]);
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final notifications = await _notifikasiService.fetchNotifikasiByNIK();
      final hasUnread = notifications.any((notif) => !notif.status);
      setState(() {
        _hasUnreadNotifications = hasUnread;
      });
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }

  Future<void> _loadJumlahReservasi() async {
    try {
      final reservasiList = await _reservasiService.fetchReservasiByNIK();
      final activeReservasi = reservasiList.where((r) =>
          r.status.toLowerCase() == 'menunggu' ||
          r.status.toLowerCase() == 'dikonfirmasi').length;

      setState(() {
        _jumlahReservasi = activeReservasi;
      });
    } catch (e) {
      debugPrint('Error loading reservasi: $e');
    }
  }

  Future<void> _loadJumlahRekamMedis() async {
    try {
      final rekamMedisList = await _rekamMedisService.fetchRekamMedisSaya();
      setState(() {
        _jumlahRekamMedis = rekamMedisList.length;
      });
    } catch (e) {
      debugPrint('Error loading rekam medis: $e');
    }
  }

  Future<void> _loadTotalSaldo() async {
    try {
      if (_nik.isEmpty) return;
      final dompetList = await DompetMedisService.fetchDompetMedisByNik(_nik);
      double total = 0;
      for (var dompet in dompetList) {
        total += dompet.saldoSisa;
      }
      setState(() {
        _totalSaldo = total;
      });
    } catch (e) {
      debugPrint('Error loading saldo: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadPatientData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      patientName: _patientName,
                      hasUnreadNotifications: _hasUnreadNotifications,
                      onNotificationPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotifikasiScreen(),
                          ),
                        );
                        _checkUnreadNotifications();
                      },
                      onChatPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const KritikSaranScreen()),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ServicesCard(
                            onReservasiTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReservasiScreen()),
                            ),
                            onRekamMedisTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RekamMedisScreen()),
                            ),
                            onDompetMedisTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DompetMedisScreen()),
                            ),
                            onPoliTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PoliScreen()),
                            ),
                            onKalenderTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => KalenderScreen()),
                            ),
                            onDaftarDokterTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DaftarDokterScreen()),
                            ),
                          ),
                          const SizedBox(height: 20),
                          QuickStatsCard(
                            isLoading: _isLoadingStats,
                            jumlahReservasi: _jumlahReservasi,
                            jumlahRekamMedis: _jumlahRekamMedis,
                            totalSaldo: _totalSaldo,
                            hasUnreadNotifications: _hasUnreadNotifications,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  CupertinoIcons.news_solid,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Berita Kesehatan Terkini',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const BeritaWidget(),
                          const SizedBox(height: 24),
                          const EmergencyContactCard(),
                          const SizedBox(height: 80), // Spasi bawah tambahan
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === Tombol "Tentang Kami" Floating di kanan bawah ===
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.amber[700],
                elevation: 6,
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text(
                  "Tentang Kami",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileTentangScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
