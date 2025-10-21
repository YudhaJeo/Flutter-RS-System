// D:\Mobile App\flutter_sistem_rs\lib\screens\login\login_screen.dart
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _rekamMedisController,
                  decoration: const InputDecoration(
                    labelText: 'No Rekam Medis',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tanggalLahirController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir (yyyy-MM-dd)',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _tanggalLahirController.text = picked
                          .toIso8601String()
                          .substring(0, 10);
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
