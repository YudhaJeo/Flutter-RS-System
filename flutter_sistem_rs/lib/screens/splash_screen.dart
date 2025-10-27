import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function(BuildContext) onFinish;
  const SplashScreen({required this.onFinish, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final norekammedis = prefs.getString('norekammedis');

        if (norekammedis != null) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
