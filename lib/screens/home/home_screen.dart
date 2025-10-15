// D:\Mobile App\flutter_sistem_rs\lib\screens\home\home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Sistem RS')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selamat datang di Home!'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
