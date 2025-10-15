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
    final res = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
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
      setState(() {
        _editMode = false;
      });
      _fetchProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil! (${res.statusCode})')),
      );
    }
  }

  Future<void> _fetchAsuransi() async {
    final uri = Uri.parse('http://10.0.2.2:4100/profile/asuransi');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      setState(() {
        _asuransiList = List<Map<String, dynamic>>.from(data);
      });
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_profile == null) {
      return const Center(child: Text('Data profil tidak ditemukan'));
    }
    String _formatDate(String? s) {
      if (s == null) return '-';
      try {
        // Database format: yyyy-MM-dd
        final dt = DateTime.parse(s);
        return DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        return s;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 54,
              backgroundColor: Colors.deepPurple.shade50,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Image.asset(
                  _profile!["JENISKELAMIN"] == 'L'
                      ? 'assets/icons/male-avatar.png'
                      : 'assets/icons/female-avatar.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profil Pasien',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'Logout',
                    onPressed: () async {
                      final konfirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin logout?',
                          ),
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
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _editMode ? Icons.save : Icons.edit,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (_editMode) {
                        _simpanProfile();
                      } else {
                        setState(() {
                          _editMode = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _item("No. Rekam Medis", _profile!["NOREKAMMEDIS"], false),
          _item("Nama Lengkap", _profile!["NAMALENGKAP"], false),
          _item("NIK", _profile!["NIK"], false),
          _item("Tanggal Lahir", _formatDate(_profile!["TANGGALLAHIR"]), false),
          _item(
            "Jenis Kelamin",
            _profile!["JENISKELAMIN"] == 'L' ? 'Laki-laki' : 'Perempuan',
            false,
          ),
          _editField("Alamat Domisili", _alamatController, _editMode),
          _item("Alamat KTP", _profile!["ALAMAT_KTP"], false),
          _editField(
            "No HP",
            _nohpController,
            _editMode,
            keyboard: TextInputType.phone,
          ),
          _editField(
            "Usia",
            _usiaController,
            _editMode,
            keyboard: TextInputType.number,
          ),
          _item("Gol. Darah", _profile!["GOLDARAH"] ?? '-', false),
          _asuransiField(),
          //_editField("No Asuransi", _noasuransiController, _editMode), <- Tidak tampilkan sesuai permintaan
          _item(
            "Tanggal Daftar",
            _formatDate(_profile!["TANGGALDAFTAR"]),
            false,
          ),
        ],
      ),
    );
  }

  Widget _item(String label, dynamic value, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 135,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${value ?? '-'}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: editable ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    bool editable, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 135,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          if (editable)
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboard,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                controller.text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }

  Widget _asuransiField() {
    if (!_editMode) {
      // Tampil NAMAASURANSI (bukan ID)
      String nama = '-';
      if (_profile != null &&
          _profile!["IDASURANSI"] != null &&
          _asuransiList.isNotEmpty) {
        final found = _asuransiList.firstWhere(
          (a) =>
              a["IDASURANSI"].toString() == _profile!["IDASURANSI"].toString(),
          orElse: () => {"NAMAASURANSI": "-"},
        );
        nama = found["NAMAASURANSI"];
      }
      return _item("Asuransi", nama, false);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 135,
              child: Text('Asuransi', style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _idasuransiController.text.isEmpty
                    ? null
                    : _idasuransiController.text,
                items: _asuransiList
                    .map(
                      (a) => DropdownMenuItem<String>(
                        value: a["IDASURANSI"].toString(),
                        child: Text(a["NAMAASURANSI"]),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _idasuransiController.text = val ?? '');
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
