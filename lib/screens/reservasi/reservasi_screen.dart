import 'package:flutter/material.dart';

class ReservasiScreen extends StatelessWidget {
  const ReservasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Halaman Reservasi'),
      ),
    );
  }
}
