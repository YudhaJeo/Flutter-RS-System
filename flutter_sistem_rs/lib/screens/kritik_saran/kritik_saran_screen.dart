import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/kritik_saran_model.dart';
import '../../services/kritik_saran_service.dart';
import '../../widgets/custom_topbar.dart';

class KritikSaranScreen extends StatefulWidget {
  const KritikSaranScreen({super.key});

  @override
  State<KritikSaranScreen> createState() => _KritikSaranScreenState();
}

class _KritikSaranScreenState extends State<KritikSaranScreen> {
  final KritikSaranService _service = KritikSaranService();
  List<KritikSaran> _list = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final result = await _service.fetchKritikSaranByNIK();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  void _tambahKritikSaran() async {
    final jenisController = TextEditingController();
    final pesanController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Kritik / Saran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Pelayanan', child: Text('Pelayanan')),
                  DropdownMenuItem(value: 'Fasilitas', child: Text('Fasilitas')),
                  DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
                  DropdownMenuItem(value: 'Perawat', child: Text('Perawat')),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
                onChanged: (v) => jenisController.text = v ?? '',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pesanController,
                decoration: InputDecoration(
                  labelText: 'Pesan',
                  hintText: 'Tuliskan kritik atau saran Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Batal'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim'),
                    onPressed: () async {
                      if (jenisController.text.isEmpty ||
                          pesanController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lengkapi semua field!')),
                        );
                        return;
                      }

                      await _service.tambahKritikSaran(
                        jenis: jenisController.text,
                        pesan: pesanController.text,
                        createdAt: DateTime.now(),
                      );

                      if (context.mounted) Navigator.pop(context, true);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (result == true) _fetchData();
  }

  Future<void> _hapusKritikSaran(KritikSaran item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Data'),
        content: const Text('Apakah kamu yakin ingin menghapus kritik/saran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await _service.hapusKritikSaran(item.idKritikSaran);
      _fetchData();
    }
  }

  String _formatTanggal(DateTime tanggal) {
    final localTime = tanggal.toLocal();
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: CustomTopBar(title: 'Kritik & Saran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _list.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada kritik/saran',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final item = _list[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            elevation: 3,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.comment, color: Colors.lightBlue),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.jenis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => _hapusKritikSaran(item),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.pesan,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTanggal(item.createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
floatingActionButton: Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        spreadRadius: 2,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: FloatingActionButton(
    onPressed: _tambahKritikSaran, // ganti dengan fungsi kamu sendiri
    backgroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Icon(Icons.add, size: 32, color: Colors.lightBlue),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}