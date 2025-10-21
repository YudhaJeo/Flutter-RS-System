import 'package:flutter/material.dart';

class DaftarDokterScreen extends StatelessWidget {
  const DaftarDokterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dokter'),
        backgroundColor: const Color.fromARGB(255, 66, 159, 235),
      ),
      body: const Center(child: Text('Halaman Daftar Dokter')),
    );
  }
}
