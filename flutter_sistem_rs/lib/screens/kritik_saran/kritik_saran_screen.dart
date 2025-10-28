import 'package:flutter/material.dart';
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
      setState(() {
        _isLoading = true;
      });
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
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kritik / Saran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jenis'),
              items: const [
                DropdownMenuItem(value: 'Pelayanan', child: Text('Pelayanan')),
                DropdownMenuItem(value: 'Fasilitas', child: Text('Fasilitas')),
                DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
                DropdownMenuItem(value: 'Perawat', child: Text('Perawat')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (v) => jenisController.text = v ?? '',
            ),
            TextField(
              controller: pesanController,
              decoration: const InputDecoration(labelText: 'Pesan'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Kirim'),
            onPressed: () async {
              if (jenisController.text.isEmpty || pesanController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lengkapi semua field!')),
                );
                return;
              }
              await _service.tambahKritikSaran(
                jenis: jenisController.text,
                pesan: pesanController.text,
              );
              if (context.mounted) Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) _fetchData();
  }

  Future<void> _hapusKritikSaran(KritikSaran item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah kamu yakin ingin menghapus kritik/saran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (konfirmasi == true) {
      await _service.hapusKritikSaran(item.idKritikSaran);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(title: 'Kritik & Saran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _list.isEmpty
                  ? const Center(child: Text('Belum ada kritik/saran'))
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.builder(
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final item = _list[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(item.jenis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item.pesan),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusKritikSaran(item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahKritikSaran,
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
