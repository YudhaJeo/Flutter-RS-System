// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\screens\register\otp_verification_screen.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import '../../utils/app_env.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String norekammedis;
  final String password;
  final String phoneNumber;
  final String otpId;

  const OtpVerificationScreen({
    super.key,
    required this.norekammedis,
    required this.password,
    required this.phoneNumber,
    required this.otpId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

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

  String _maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 2);
    final masked = '*' * (phone.length - 6);
    return '$start$masked$end';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showToast('Masukkan kode OTP lengkap', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('${AppEnv.baseUrl}/register/verify-otp');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otpId': widget.otpId,
          'otp': otp,
          'norekammedis': widget.norekammedis,
          'password': widget.password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showToast(data['message'] ?? 'Registrasi berhasil');

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        _showToast(data['message'] ?? 'Kode OTP tidak valid', isError: true);

        // Clear OTP fields on error
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      _showToast('Gagal terhubung ke server', isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;

    setState(() {
      _isResending = true;
    });

    final uri = Uri.parse('${AppEnv.baseUrl}/register/resend-otp');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'norekammedis': widget.norekammedis}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showToast('Kode OTP berhasil dikirim ulang');
        _startCountdown();

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        _showToast(
          data['message'] ?? 'Gagal mengirim ulang OTP',
          isError: true,
        );
      }
    } catch (e) {
      _showToast('Gagal terhubung ke server', isError: true);
    }

    setState(() {
      _isResending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verifikasi OTP',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF42A5F5),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),

                // Title and description
                const Text(
                  "Masukkan Kode Verifikasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Kode OTP telah dikirim ke nomor\n${_maskPhoneNumber(widget.phoneNumber)}",
                  style: const TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // OTP Input Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 48,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus
                                      ? const Color(0xFF42A5F5)
                                      : Colors.grey.shade300,
                                  width: _focusNodes[index].hasFocus ? 2 : 1.5,
                                ),
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    setState(() {}); // Refresh border color

                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }

                                    // Auto verify when all fields filled
                                    if (index == 5 && value.isNotEmpty) {
                                      final allFilled = _otpControllers.every(
                                        (c) => c.text.isNotEmpty,
                                      );
                                      if (allFilled) {
                                        _verifyOtp();
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF42A5F5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _verifyOtp,
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
                                    'Verifikasi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resend OTP
                        Center(
                          child: _countdown > 0
                              ? Text(
                                  'Kirim ulang kode dalam $_countdown detik',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                )
                              : TextButton(
                                  onPressed: _isResending ? null : _resendOtp,
                                  child: _isResending
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Kirim Ulang Kode OTP',
                                          style: TextStyle(
                                            color: Color(0xFF42A5F5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                        ),
                      ],
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
