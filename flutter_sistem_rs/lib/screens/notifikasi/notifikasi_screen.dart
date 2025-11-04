// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\screens\notifikasi\notifikasi_screen.dart
import 'package:flutter/material.dart';
import '../../models/notifikasi_model.dart';
import '../../services/notifikasi_service.dart';
import '../../widgets/custom_topbar.dart';
import '../../widgets/notifikasi_detail_widget.dart';
import '../../widgets/loading_widget.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final NotifikasiService _service = NotifikasiService();
  List<Notifikasi> _list = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final result = await _service.fetchNotifikasiByNIK();

      result.sort((a, b) => b.idNotifikasi.compareTo(a.idNotifikasi));

      setState(() {
        _list = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetail(Notifikasi item, int index) async {
    if (!item.status) {
      try {
        await _service.ubahStatusDibaca(item.idNotifikasi);
        setState(() {
          _list[index] = Notifikasi(
            idNotifikasi: item.idNotifikasi,
            nik: item.nik,
            namaPasien: item.namaPasien,
            tanggalReservasi: item.tanggalReservasi,
            namaPoli: item.namaPoli,
            namaDokter: item.namaDokter,
            judul: item.judul,
            pesan: item.pesan,
            status: true,
          );
        });
      } catch (e) {
        debugPrint('Error marking as read: $e');
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotifikasiDetailModal(notifikasi: _list[index]),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(title: 'Notifikasi'),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat notifikasi...')
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi Anda akan muncul di sini',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  final item = _list[index];
                  final isRead = item.status;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isRead ? 0.5 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openDetail(item, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(
                                    top: 4,
                                    right: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isRead
                                        ? Colors.grey.shade300
                                        : Colors.blue.shade600,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.judul,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isRead
                                              ? FontWeight.w500
                                              : FontWeight.bold,
                                          color: isRead
                                              ? Colors.black87
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _truncateText(item.pesan, 80),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isRead
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
