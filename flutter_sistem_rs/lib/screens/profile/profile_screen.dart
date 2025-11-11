// D:\Mobile App\flutter_sistem_rs\lib\screens\profile\profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'profile_not_found_screen.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/app_env.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editMode = false;
  final _alamatController = TextEditingController();
  final _nohpController = TextEditingController();
  final _usiaController = TextEditingController();
  final _idasuransiController = TextEditingController();
  final _noasuransiController = TextEditingController();
  List<Map<String, dynamic>> _asuransiList = [];

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final idPasien = prefs.getInt('idPasien');
    if (idPasien == null) return;
    final uri = Uri.parse('${AppEnv.baseUrl}/profile?id=$idPasien');
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'];
      setState(() {
        _profile = data;
        _alamatController.text = data['ALAMAT'] ?? '';
        _nohpController.text = data['NOHP'] ?? '';
        _usiaController.text = data['USIA'] ?? '';
        _idasuransiController.text = data['IDASURANSI']?.toString() ?? '';
        _noasuransiController.text = data['NOASURANSI'] ?? '';
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _simpanProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idPasien = prefs.getInt('idPasien');
    if (idPasien == null) return;
    final uri = Uri.parse('${AppEnv.baseUrl}/profile');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': idPasien,
        'alamat': _alamatController.text,
        'nohp': _nohpController.text,
        'usia': _usiaController.text,
        'idasuransi': _idasuransiController.text,
        'noasuransi': _noasuransiController.text,
      }),
    );
    if (res.statusCode == 200) {
      setState(() => _editMode = false);
      _fetchProfile();
      Fluttertoast.showToast(
        msg: "Profil berhasil disimpan!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Gagal menyimpan profil (${res.statusCode})',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  Future<void> _fetchAsuransi() async {
    final uri = Uri.parse('${AppEnv.baseUrl}/profile/asuransi');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      setState(() => _asuransiList = List<Map<String, dynamic>>.from(data));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchAsuransi();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingScreen(
        message: 'Memuat profil...',
      );
    }
    
    if (_profile == null) {
      return const ProfileNotFoundScreen();
    }

    String formatDate(String? s) {
      if (s == null) return '-';
      try {
        final dt = DateTime.parse(s);
        return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
      } catch (_) {
        return s;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header + tombol logout
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[700]!,
                        Colors.blue[500]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade50,
                            child: Image.asset(
                              _profile!["JENISKELAMIN"] == 'L'
                                  ? 'assets/icons/male-avatar.png'
                                  : 'assets/icons/female-avatar.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _profile!["NAMALENGKAP"] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "No. RM: ${_profile!["NOREKAMMEDIS"] ?? '-'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol logout di pojok kanan atas
                Positioned(
                  right: 16,
                  top: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.logout, color: Colors.white, size: 28),
                      onPressed: () async {
                        final konfirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.logout, color: Colors.redAccent),
                                SizedBox(width: 12),
                                Text('Logout'),
                              ],
                            ),
                            content:
                                const Text('Apakah Anda yakin ingin keluar?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (konfirm == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (!mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Konten
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionCard(
                    title: "Data Pribadi",
                    icon: Icons.person_outline,
                    children: [
                      _item(Icons.badge_outlined, "NIK", _profile!["NIK"]),
                      _item(Icons.cake_outlined, "Tanggal Lahir",
                          formatDate(_profile!["TANGGALLAHIR"])),
                      _item(
                          Icons.people_outline,
                          "Jenis Kelamin",
                          _profile!["JENISKELAMIN"] == 'L'
                              ? 'Laki-laki'
                              : 'Perempuan'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Kontak & Domisili",
                    icon: Icons.location_on_outlined,
                    children: [
                      _editField(Icons.home_outlined, "Alamat Domisili",
                          _alamatController, _editMode),
                      _item(Icons.location_city_outlined, "Alamat KTP",
                          _profile!["ALAMAT_KTP"]),
                      _editField(Icons.phone_outlined, "No HP", _nohpController,
                          _editMode,
                          keyboard: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Informasi Tambahan",
                    icon: Icons.info_outline,
                    children: [
                      _editField(Icons.accessibility_outlined, "Usia",
                          _usiaController, _editMode,
                          keyboard: TextInputType.number),
                      _item(Icons.bloodtype_outlined, "Golongan Darah",
                          _profile!["GOLDARAH"] ?? '-'),
                      _asuransiField(),
                      _item(Icons.calendar_today_outlined, "Tanggal Daftar",
                          formatDate(_profile!["TANGGALDAFTAR"])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 220,
                      child: _buildGradientButton(
                        icon: _editMode ? Icons.save : Icons.edit,
                        label: _editMode ? 'Simpan' : 'Edit Profil',
                        onPressed: () {
                          if (_editMode) {
                            _simpanProfile();
                          } else {
                            setState(() => _editMode = true);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper ---
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.blueAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.blue.shade300],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${value ?? '-'}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(
      IconData icon, String label, TextEditingController controller, bool editable,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsets.only(top: editable ? 12 : 0),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: editable
                ? TextFormField(
                    controller: controller,
                    keyboardType: keyboard,
                    decoration: InputDecoration(
                      labelText: label,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: Colors.blueAccent, width: 2),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? '-' : controller.text,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _asuransiField() {
    if (_editMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.blueAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _idasuransiController.text.isNotEmpty
                    ? _idasuransiController.text
                    : null,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _idasuransiController.text = val);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Asuransi',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                items: _asuransiList
                    .map((asuransi) => DropdownMenuItem(
                          value: asuransi["IDASURANSI"].toString(),
                          child: Text(asuransi["NAMAASURANSI"]),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      final asuransiNama = _asuransiList.firstWhere(
          (a) => a["IDASURANSI"].toString() == _idasuransiController.text,
          orElse: () => {"NAMAASURANSI": "-"})["NAMAASURANSI"];
      return _item(Icons.medical_services_outlined, "Asuransi", asuransiNama);
    }
  }
}