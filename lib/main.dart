// D:\Mobile App\flutter_sistem_rs\lib\main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter RS Bayza',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(
        onFinish: _cekLoginDanRedirect,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

Future<void> _cekLoginDanRedirect(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2)); // simulasi loading
  bool isLoggedIn = false;

  if (isLoggedIn) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
