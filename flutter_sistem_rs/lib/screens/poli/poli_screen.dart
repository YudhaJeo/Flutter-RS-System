// D:\Mobile App\flutter_sistem_rs\lib\screens\poli\poli_screen.dart
import 'package:flutter/material.dart';
import '../../models/poli_model.dart';
import '../../services/poli_service.dart';

class PoliScreen extends StatefulWidget {
  const PoliScreen({super.key});

  @override
  State<PoliScreen> createState() => _PoliScreenState();
}

class _PoliScreenState extends State<PoliScreen> {
  final PoliService _poliService = PoliService();
  List<Poli> _poliList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPoli();
  }

  Future<void> _fetchPoli() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final poliList = await _poliService.fetchAllPoli();

      // 🔹 Urutkan berdasarkan nama poli (A-Z)
      poliList.sort((a, b) => a.namaPoli.toLowerCase().compareTo(b.namaPoli.toLowerCase()));

      setState(() {
        _poliList = poliList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Poli'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _poliList.isEmpty
                  ? const Center(child: Text('Tidak ada data poli'))
                  : RefreshIndicator(
                      onRefresh: _fetchPoli,
                      child: ListView.builder(
                        itemCount: _poliList.length,
                        itemBuilder: (context, index) {
                          final poli = _poliList[index];
                          return ListTile(
                            title: Text(poli.namaPoli),
                            leading: const Icon(
                              Icons.local_hospital,
                              color: Colors.deepPurple,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}