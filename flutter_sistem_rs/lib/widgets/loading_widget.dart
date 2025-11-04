// D:\Mobile App\flutter_sistem_rs\lib\widgets\loading_widget.dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final bool showLogo;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Colors.blue.shade700;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo/Icon dengan animasi pulse
          if (showLogo)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Loop animation
              },
            ),
          
          if (showLogo) const SizedBox(height: 32),
          
          // Custom circular progress indicator dengan gradient
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                  ),
                ),
                // Progress indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Loading message
          Text(
            message ?? 'Memuat data...',
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Animated dots
          _AnimatedDots(color: primaryColor),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  final Color color;

  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(opacity.clamp(0.2, 1.0)),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Scaffold wrapper untuk full-screen loading
class LoadingScreen extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? loadingColor;
  final bool showLogo;

  const LoadingScreen({
    super.key,
    this.message,
    this.backgroundColor,
    this.loadingColor,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF5F7FA),
      body: LoadingWidget(
        message: message,
        color: loadingColor,
        showLogo: showLogo,
      ),
    );
  }
}

// Overlay loading untuk menampilkan loading di atas konten
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    String? message,
    Color? color,
    bool showLogo = false,
  }) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: LoadingWidget(
          message: message,
          color: color,
          showLogo: showLogo,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}