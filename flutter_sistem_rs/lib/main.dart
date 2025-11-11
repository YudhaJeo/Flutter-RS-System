import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/register/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'widgets/main_bottom_nav.dart';
import 'screens/profile/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    // Coba load dari beberapa lokasi
    await dotenv.load(fileName: ".env");
    debugPrint("Berhasil memuat .env dari root project");
  } catch (e) {
    try {
      // Coba load dari direktori assets
      await dotenv.load(fileName: ".env");
      debugPrint("Berhasil memuat .env dari assets");
    } catch (assetsError) {
      debugPrint("Gagal memuat .env: $e, Assets Error: $assetsError");

      // Tambahkan default values jika env gagal dimuat
      dotenv.env['EXPRESS_PORT'] = '4100';
      dotenv.env['IP_ADDRESS'] = '10.0.2.2';

      debugPrint("Menggunakan default environment values");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RS Bayza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 140, 255),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.blue.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: Colors.lightBlue),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      locale: const Locale('id', 'ID'),
      home: const SplashScreen(onFinish: _cekLoginDanRedirect),
      routes: {
        '/register': (context) => const RegisterScreen(),
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
