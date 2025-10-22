import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../../utils/app_env.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _rekamMedisController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uri = Uri.parse('http://10.0.2.2:4100/login');
    // final uri = Uri.parse('http://10.127.175.73:4100/login');
    // final uri = Uri.parse('${AppEnv.baseUrl}/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'norekammedis': _rekamMedisController.text,
          'tanggallahir': _tanggalLahirController.text,
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
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        setState(() {
          _error = data['message'] ?? 'Login gagal';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal terhubung ke server';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB), // latar belakang biru muda
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
                  "Masukkan No Rekam Medis dan Tanggal Lahir Anda",
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
                          TextFormField(
                            controller: _rekamMedisController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: Color(0xFF42A5F5),
                              ),
                              labelText: 'No Rekam Medis',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF42A5F5), width: 1.2),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tanggalLahirController,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _tanggalLahirController.text =
                                    picked.toIso8601String().substring(0, 10);
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF42A5F5),
                              ),
                              labelText: 'Tanggal Lahir (yyyy-MM-dd)',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF42A5F5), width: 1.2),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          // 🔵 Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF42A5F5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 16),
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
