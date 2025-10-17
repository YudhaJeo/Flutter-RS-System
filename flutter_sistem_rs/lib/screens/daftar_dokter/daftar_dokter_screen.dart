import 'package:flutter/material.dart';

class DaftarDokterScreen extends StatelessWidget {
  const DaftarDokterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dokter'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Halaman Daftar Dokter'),
      ),
    );
  }
}
