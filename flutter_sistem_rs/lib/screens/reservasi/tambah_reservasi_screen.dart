import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/reservasi_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../../utils/app_env.dart';

class TambahReservasiScreen extends StatefulWidget {
  const TambahReservasiScreen({super.key});

  @override
  State<TambahReservasiScreen> createState() => _TambahReservasiScreenState();
}

class _TambahReservasiScreenState extends State<TambahReservasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservasiService = ReservasiService();

  // Controller untuk input
  final _keteranganController = TextEditingController();

  // Variabel untuk dropdown
  int? _selectedPoliId;
  int? _selectedDokterId;
  DateTime? _selectedTanggal;
  String? _selectedJamReservasi;
  List<String> _jamOptions = [];

  // List untuk dropdown (nanti diisi dari backend)
  List<Map<String, dynamic>> _poliList = [];
  List<Map<String, dynamic>> _dokterList = [];
  List<Map<String, dynamic>> _allDokterList = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPoliList();
    _fetchAllDokter();
  }

  Future<void> _fetchPoliList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4100/poli'),
        // Uri.parse('${AppEnv.baseUrl}/poli'),
        // Uri.parse('http://10.127.175.73:4100/poli'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> poliData = json.decode(response.body);
        setState(() {
          _poliList = poliData
              .map(
                (poli) => {
                  'IDPOLI': poli['IDPOLI'],
                  'NAMAPOLI': poli['NAMAPOLI'],
                },
              )
              .toList();
        });
      } else {
        throw Exception('Gagal memuat daftar poli');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar poli: $e';
      });
    }
  }

  Future<void> _fetchAllDokter() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4100/dokter'),
        // Uri.parse('${AppEnv.baseUrl}/dokter'),
        // Uri.parse('http://10.127.175.73:4100/dokter'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dokterData = json.decode(response.body);
        setState(() {
          _allDokterList = dokterData.map((dokter) {
            // Parsing jadwal praktek
            List<String> jadwal = [];
            if (dokter['JADWALPRAKTEK'] is String) {
              jadwal = (dokter['JADWALPRAKTEK'] as String)
                  .split(',')
                  .map((j) => j.trim())
                  .toList();
            } else if (dokter['JADWALPRAKTEK'] is List) {
              jadwal = List<String>.from(dokter['JADWALPRAKTEK']);
            }

            return {
              'IDDOKTER': dokter['IDDOKTER'],
              'NAMALENGKAP': dokter['NAMALENGKAP'],
              'IDPOLI': dokter['IDPOLI'],
              'JADWALPRAKTEK': jadwal,
            };
          }).toList();
        });
      } else {
        throw Exception('Gagal memuat daftar dokter');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar dokter: $e';
      });
    }
  }

  void _filterDokterByPoliAndTanggal() {
    if (_selectedPoliId == null || _selectedTanggal == null) {
      setState(() {
        _dokterList = [];
      });
      return;
    }

    // Dapatkan hari dari tanggal yang dipilih
    final hariDipilih = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ][_selectedTanggal!.weekday % 7];

    setState(() {
      _dokterList = _allDokterList.where((dokter) {
        // Filter berdasarkan poli
        bool poliSesuai = dokter['IDPOLI'] == _selectedPoliId;

        // Filter berdasarkan jadwal praktek
        bool jadwalSesuai = (dokter['JADWALPRAKTEK'] as List<String>).any(
          (jadwal) => jadwal.toLowerCase().contains(hariDipilih.toLowerCase()),
        );

        return poliSesuai && jadwalSesuai;
      }).toList();
    });
  }

  void _filterJamReservasi() {
    // Reset jam reservasi jika dokter atau tanggal belum dipilih
    if (_selectedDokterId == null || _selectedTanggal == null) {
      setState(() {
        _jamOptions = [];
        _selectedJamReservasi = null;
      });
      return;
    }

    // Dapatkan hari dari tanggal yang dipilih
    final hariDipilih = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ][_selectedTanggal!.weekday % 7];

    // Cari dokter yang dipilih
    final selectedDokter = _allDokterList.firstWhere(
      (dokter) => dokter['IDDOKTER'] == _selectedDokterId,
      orElse: () => {},
    );

    // Filter jam praktek berdasarkan hari
    if (selectedDokter.isNotEmpty && selectedDokter['JADWALPRAKTEK'] != null) {
      final List<String> jadwalPraktek = selectedDokter['JADWALPRAKTEK'];

      setState(() {
        _jamOptions = jadwalPraktek
            .where(
              (jadwal) =>
                  jadwal.toLowerCase().contains(hariDipilih.toLowerCase()),
            )
            .toList();

        // Reset jam reservasi jika jam sebelumnya tidak tersedia
        if (_selectedJamReservasi != null &&
            !_jamOptions.contains(_selectedJamReservasi)) {
          _selectedJamReservasi = null;
        }
      });
    } else {
      setState(() {
        _jamOptions = [];
        _selectedJamReservasi = null;
      });
    }
  }

  Future<void> _tambahReservasi() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi pilihan
    if (_selectedPoliId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Poli terlebih dahulu')),
      );
      return;
    }

    if (_selectedDokterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Dokter terlebih dahulu')),
      );
      return;
    }

    if (_selectedTanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Tanggal terlebih dahulu')),
      );
      return;
    }

    if (_selectedJamReservasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Jam Praktek terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final nik = prefs.getString('nik');

      if (nik == null) {
        throw Exception('NIK tidak ditemukan. Silakan login ulang.');
      }

      await _reservasiService.tambahReservasi(
        idPoli: _selectedPoliId!,
        idDokter: _selectedDokterId!,
        keterangan: _keteranganController.text.trim(),
        jamReservasi: _selectedJamReservasi!,
        // Tambahkan satu hari untuk mengatasi masalah zona waktu
        tanggalReservasi: DateTime(
          _selectedTanggal!.year,
          _selectedTanggal!.month,
          _selectedTanggal!.day,
        ).add(Duration(days: 1)).toUtc().toIso8601String().split('T')[0],
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservasi berhasil ditambahkan')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah reservasi: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Reservasi'),
        backgroundColor: const Color.fromARGB(255, 64, 140, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Reservasi',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedTanggal == null
                      ? ''
                      : '${_selectedTanggal!.day}/${_selectedTanggal!.month}/${_selectedTanggal!.year}',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedTanggal = pickedDate;
                      _selectedDokterId = null; // Reset dokter
                      _selectedJamReservasi = null; // Reset jam reservasi
                      _filterDokterByPoliAndTanggal(); // Filter dokter
                      _filterJamReservasi(); // Filter jam praktek
                    });
                  }
                },
                validator: (value) =>
                    _selectedTanggal == null ? 'Pilih Tanggal' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Poli
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Poli',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPoliId,
                items: _poliList.map((poli) {
                  return DropdownMenuItem<int>(
                    value: (poli['IDPOLI'] as int),
                    child: Text(poli['NAMAPOLI'] ?? '-'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPoliId = value;
                    _selectedDokterId = null; // Reset dokter
                    _selectedJamReservasi = null; // Reset jam reservasi
                    _filterDokterByPoliAndTanggal(); // Filter dokter
                    _filterJamReservasi(); // Filter jam praktek
                  });
                },
                validator: (value) => value == null ? 'Pilih Poli' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Dokter (aktif setelah poli dan tanggal dipilih)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Dokter',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDokterId,
                items: _dokterList.map((dokter) {
                  return DropdownMenuItem<int>(
                    value: (dokter['IDDOKTER'] as int),
                    child: Text(dokter['NAMALENGKAP'] ?? '-'),
                  );
                }).toList(),
                onChanged: (_selectedPoliId == null || _selectedTanggal == null)
                    ? null
                    : (value) {
                        setState(() {
                          _selectedDokterId = value;
                          _selectedJamReservasi = null; // Reset jam reservasi
                          _filterJamReservasi(); // Filter jam praktek
                        });
                      },
                validator: (value) => value == null ? 'Pilih Dokter' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Jam Reservasi (aktif setelah dokter dipilih)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Jam Praktek',
                  border: OutlineInputBorder(),
                ),
                value: _selectedJamReservasi,
                items: _jamOptions.map((jam) {
                  return DropdownMenuItem<String>(value: jam, child: Text(jam));
                }).toList(),
                onChanged: (_selectedDokterId == null)
                    ? null
                    : (value) {
                        setState(() {
                          _selectedJamReservasi = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Pilih Jam Praktek' : null,
              ),
              const SizedBox(height: 16),

              // Keterangan (opsional)
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Tombol Tambah
              ElevatedButton(
                onPressed: _isLoading ? null : _tambahReservasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 66, 159, 235),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Tambah Reservasi',
                        style: TextStyle(fontSize: 16),
                      ),
              ),

              // Tampilkan pesan error jika ada
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
