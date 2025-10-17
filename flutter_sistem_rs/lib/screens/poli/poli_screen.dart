import 'package:flutter/material.dart';

class PoliScreen extends StatelessWidget {
  const PoliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poli'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Halaman Poli'),
      ),
    );
  }
}
