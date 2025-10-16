import 'package:flutter/material.dart';

class RekamMedisScreen extends StatelessWidget {
  const RekamMedisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekam Medis'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Halaman Rekam Medis'),
      ),
    );
  }
}
