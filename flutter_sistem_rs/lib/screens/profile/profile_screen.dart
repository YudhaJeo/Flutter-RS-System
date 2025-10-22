// D:\Mobile App\flutter_sistem_rs\lib\screens\profile\profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
    final uri = Uri.parse('http://10.0.2.2:4100/profile?id=$idPasien');
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});
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
    final uri = Uri.parse('http://10.0.2.2:4100/profile');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil (${res.statusCode})')),
      );
    }
  }

  Future<void> _fetchAsuransi() async {
    final uri = Uri.parse('http://10.0.2.2:4100/profile/asuransi');
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_profile == null) {
      return const Center(child: Text('Data profil tidak ditemukan'));
    }

    String _formatDate(String? s) {
      if (s == null) return '-';
      try {
        final dt = DateTime.parse(s);
        return DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        return s;
      }
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      _profile!["JENISKELAMIN"] == 'L'
                          ? 'assets/icons/male-avatar.png'
                          : 'assets/icons/female-avatar.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _profile!["NAMALENGKAP"],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "No. RM: ${_profile!["NOREKAMMEDIS"]}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ======= CARD PROFILE DETAIL =======
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _sectionTitle("Data Pribadi"),
                    _item(Icons.badge, "NIK", _profile!["NIK"]),
                    _item(Icons.cake, "Tanggal Lahir", _formatDate(_profile!["TANGGALLAHIR"])),
                    _item(Icons.person, "Jenis Kelamin",
                        _profile!["JENISKELAMIN"] == 'L' ? 'Laki-laki' : 'Perempuan'),
                    const Divider(),
                    _sectionTitle("Kontak & Domisili"),
                    _editField(Icons.home, "Alamat Domisili", _alamatController, _editMode),
                    _item(Icons.location_on, "Alamat KTP", _profile!["ALAMAT_KTP"]),
                    _editField(Icons.phone, "No HP", _nohpController, _editMode,
                        keyboard: TextInputType.phone),
                    const Divider(),
                    _sectionTitle("Informasi Tambahan"),
                    _editField(Icons.accessibility, "Usia", _usiaController, _editMode,
                        keyboard: TextInputType.number),
                    _item(Icons.bloodtype, "Golongan Darah", _profile!["GOLDARAH"] ?? '-'),
                    _asuransiField(),
                    _item(Icons.calendar_today, "Tanggal Daftar", _formatDate(_profile!["TANGGALDAFTAR"])),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // ======= BUTTONS =======
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_editMode ? Icons.save : Icons.edit),
                    label: Text(_editMode ? 'Simpan Perubahan' : 'Edit Profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_editMode) {
                        _simpanProfile();
                      } else {
                        setState(() => _editMode = true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 22),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final konfirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
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
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      );

  Widget _item(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text("$label: ${value ?? '-'}",
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _editField(IconData icon, String label, TextEditingController controller, bool editable,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 8),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  )
                : Text("$label: ${controller.text}",
                    style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _asuransiField() {
    if (!_editMode) {
      String nama = '-';
      if (_profile != null &&
          _profile!["IDASURANSI"] != null &&
          _asuransiList.isNotEmpty) {
        final found = _asuransiList.firstWhere(
          (a) => a["IDASURANSI"].toString() == _profile!["IDASURANSI"].toString(),
          orElse: () => {"NAMAASURANSI": "-"},
        );
        nama = found["NAMAASURANSI"];
      }
      return _item(Icons.health_and_safety, "Asuransi", nama);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _idasuransiController.text.isEmpty
                    ? null
                    : _idasuransiController.text,
                items: _asuransiList
                    .map((a) => DropdownMenuItem<String>(
                          value: a["IDASURANSI"].toString(),
                          child: Text(a["NAMAASURANSI"]),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _idasuransiController.text = val ?? ''),
                decoration: InputDecoration(
                  labelText: "Asuransi",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
