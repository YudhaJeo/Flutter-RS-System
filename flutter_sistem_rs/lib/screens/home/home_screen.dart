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
import '../../widgets/berita_widget.dart';
import '../../services/notifikasi_service.dart';
import '../../services/reservasi_service.dart';
import '../../services/rekammedis_service.dart';
import '../../services/dompet_medis_service.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  int _totalSaldo = 0;
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
      // Load semua data secara parallel
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
      // Hitung hanya reservasi yang statusnya "Menunggu" atau "Dikonfirmasi"
      final activeReservasi = reservasiList.where((r) => 
        r.status.toLowerCase() == 'menunggu' || 
        r.status.toLowerCase() == 'dikonfirmasi'
      ).length;
      
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
    // Pastikan NIK tersedia
    if (_nik.isEmpty) {
      debugPrint('⚠️ NIK kosong, tidak memuat saldo.');
      return;
    }

    // Ambil data dompet medis dari API
    final dompetList = await DompetMedisService.fetchDompetMedisByNik(_nik);

    // Hitung total deposit
    int total = dompetList.fold<int>(
      0,
      (sum, item) => sum + ((item.jumlahDeposit).toInt()),
    );

    // Update state hanya kalau widget masih aktif
    if (mounted) {
      setState(() {
        _totalSaldo = total;
      });
    }

    debugPrint('✅ Total saldo berhasil dimuat: $_totalSaldo');

  } catch (e, stack) {
    debugPrint('❌ Gagal memuat saldo: $e');
    debugPrintStack(stackTrace: stack);

    // Bisa tampilkan toast biar user tahu
    Fluttertoast.showToast(
      msg: 'Gagal memuat saldo, periksa koneksi Anda.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red[700],
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}


  Future<void> _refreshData() async {
    await Future.wait([
      _loadPatientData(),
    ]);
  }

  Future<void> _makeEmergencyCall() async {
    const phoneNumber = 'tel:119'; 
    final uri = Uri.parse(phoneNumber);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat melakukan panggilan darurat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making emergency call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal melakukan panggilan darurat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xFFF5F7FA),
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[700]!,
                        Colors.blue[500]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hai,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    _patientName,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Semangat jaga kesehatanmu hari ini!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.bell_fill,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const NotifikasiScreen(),
                                            ),
                                          );
                                          _checkUnreadNotifications();
                                        },
                                      ),
                                    ),
                                    if (_hasUnreadNotifications)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      CupertinoIcons.chat_bubble_text_fill,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const KritikSaranScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Services Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.square_grid_2x2_fill,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Layanan Kami',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
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
                                    CupertinoIcons.doc_text_fill,
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
                                    CupertinoIcons.creditcard_fill,
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
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Quick Stats Card
                      _buildQuickStatsCard(),
                      
                      const SizedBox(height: 20),

                      // Emergency Contact Card
                      _buildEmergencyCard(),

                      const SizedBox(height: 24),

                      // News Section
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.chart_bar_fill,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ringkasan Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoadingStats)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      CupertinoIcons.calendar_badge_plus,
                      'Reservasi Aktif',
                      '$_jumlahReservasi',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      CupertinoIcons.doc_text,
                      'Rekam Medis',
                      '$_jumlahRekamMedis',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      CupertinoIcons.money_dollar_circle,
                      'Saldo Dompet',
                      'Rp ${_formatCurrency(_totalSaldo)}',
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      CupertinoIcons.bell,
                      'Notifikasi',
                      _hasUnreadNotifications ? 'Ada Baru' : 'Semua Dibaca',
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red[400]!.withOpacity(0.1),
              Colors.orange[400]!.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.antenna_radiowaves_left_right,
                      color: Colors.red[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kontak Darurat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _makeEmergencyCall,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red[600]!,
                        Colors.red[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.phone_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hubungi Ambulans',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '119',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '24/7 Siap Siaga',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '⚠️ Gunakan hanya untuk keadaan darurat medis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[600]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}