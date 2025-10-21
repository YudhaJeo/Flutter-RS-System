import 'package:flutter/material.dart';

class DompetMedisScreen extends StatelessWidget {
  const DompetMedisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet Medis'),
        backgroundColor: const Color.fromARGB(255, 66, 159, 235),
      ),
      body: const Center(child: Text('Halaman Dompet Medis')),
    );
  }
}
