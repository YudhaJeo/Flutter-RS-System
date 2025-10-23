// D:\Mobile App\flutter_sistem_rs\lib\main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/main_bottom_nav.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    print(dotenv.env);
  } catch (e) {
    print("Error loading .env file: $e");
  }
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 140, 255),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // 🩵 font global
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(
            color: Colors.lightBlue, // warna ikon default (misal tombol back)
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(onFinish: _cekLoginDanRedirect),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/main': (context) => const MainNavScreen(),
      },
    );
  }
}

Future<void> _cekLoginDanRedirect(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
}