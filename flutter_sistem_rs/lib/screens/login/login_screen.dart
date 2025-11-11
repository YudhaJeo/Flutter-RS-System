import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/app_env.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identitasController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('${AppEnv.baseUrl}/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'norekammedis': _identitasController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final pasien = data['pasien'];
        await prefs.setInt('idPasien', pasien['IDPASIEN']);
        await prefs.setString('norekammedis', pasien['NOREKAMMEDIS']);
        await prefs.setString('namaLengkap', pasien['NAMALENGKAP']);
        await prefs.setString('nik', pasien['NIK']);

        _showToast(data['message'] ?? 'Login berhasil');

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        _showToast(data['message'] ?? 'Login gagal', isError: true);
      }
    } catch (e) {
      _showToast(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
        isError: true,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  void dispose() {
    _identitasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🏥 Ikon rumah sakit di atas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF42A5F5),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),

                // 🩺 Judul dan deskripsi
                const Text(
                  "Selamat Datang di Rumah Sakit Bayza Medika!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masuk untuk mengakses layanan kesehatan Anda",
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 📋 Form Login
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Input No Rekam Medis / NIK
                          TextFormField(
                            controller: _identitasController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: Color(0xFF42A5F5),
                              ),
                              labelText: 'No Rekam Medis / NIK',
                              hintText: 'Masukkan No Rekam Medis atau NIK',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'No Rekam Medis / NIK wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF42A5F5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              labelText: 'Password',
                              hintText: 'Masukkan password',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Password wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // 🔵 Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF42A5F5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade400),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'atau',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 📝 Tombol Register
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF42A5F5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _goToRegister,
                              child: const Text(
                                'Daftar Akun Baru',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "© 2025 Rumah Sakit Bayza Medika",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
