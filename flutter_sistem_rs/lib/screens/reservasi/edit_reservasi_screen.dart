import 'package:flutter/material.dart';
import '../../services/reservasi_service.dart';
import '../../models/reservasi_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import '../../widgets/custom_topbar.dart';

class EditReservasiScreen extends StatefulWidget {
  final Reservasi reservasi;

  const EditReservasiScreen({super.key, required this.reservasi});

  @override
  State<EditReservasiScreen> createState() => _EditReservasiScreenState();
}

class _EditReservasiScreenState extends State<EditReservasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservasiService = ReservasiService();

  final _keteranganController = TextEditingController();
  int? _selectedPoliId;
  int? _selectedDokterId;
  DateTime? _selectedTanggal;
  String? _selectedJamReservasi;
  List<String> _jamOptions = [];

  List<Map<String, dynamic>> _poliList = [];
  List<Map<String, dynamic>> _dokterList = [];
  List<Map<String, dynamic>> _allDokterList = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeReservasiData();
    _fetchPoliList();
    _fetchAllDokter();
  }

  void _initializeReservasiData() {
    _selectedPoliId = widget.reservasi.idPoli;
    _selectedDokterId = widget.reservasi.idDokter;

    final tanggalReservasi = DateTime.parse(widget.reservasi.tanggalReservasi)
        .add(const Duration(days: 1));
    _selectedTanggal = tanggalReservasi;

    _selectedJamReservasi = widget.reservasi.jamReservasi;
    _keteranganController.text = widget.reservasi.keterangan ?? '';

    debugPrint(
        'Init Reservasi: ${widget.reservasi.tanggalReservasi} -> $tanggalReservasi');
  }

  void _updateFiltersAfterInitialization() {
    if (_selectedPoliId != null && _selectedTanggal != null) {
      _filterDokterByPoliAndTanggal();
      _filterJamReservasi();
    }
  }

  Future<void> _fetchPoliList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4100/poli'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _poliList = data
              .map((p) => {'IDPOLI': p['IDPOLI'], 'NAMAPOLI': p['NAMAPOLI']})
              .toList();
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat poli: $e');
    }
  }

  Future<void> _fetchAllDokter() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4100/dokter'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allDokterList = data.map((d) {
            List<String> jadwal = [];
            if (d['JADWALPRAKTEK'] is String) {
              jadwal = (d['JADWALPRAKTEK'] as String)
                  .split(',')
                  .map((j) => j.trim())
                  .toList();
            } else if (d['JADWALPRAKTEK'] is List) {
              jadwal = List<String>.from(d['JADWALPRAKTEK']);
            }
            return {
              'IDDOKTER': d['IDDOKTER'],
              'NAMALENGKAP': d['NAMALENGKAP'],
              'IDPOLI': d['IDPOLI'],
              'JADWALPRAKTEK': jadwal,
            };
          }).toList();
          _updateFiltersAfterInitialization();
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat dokter: $e');
    }
  }

  void _filterDokterByPoliAndTanggal() {
    if (_selectedPoliId == null || _selectedTanggal == null) {
      setState(() => _dokterList = []);
      return;
    }
    final hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ][_selectedTanggal!.weekday % 7];

    setState(() {
      _dokterList = _allDokterList.where((d) {
        bool poliMatch = d['IDPOLI'] == _selectedPoliId;
        bool jadwalMatch = (d['JADWALPRAKTEK'] as List<String>)
            .any((j) => j.toLowerCase().contains(hari.toLowerCase()));
        return poliMatch && jadwalMatch;
      }).toList();
    });
  }

  void _filterJamReservasi() {
    if (_selectedDokterId == null || _selectedTanggal == null) {
      setState(() {
        _jamOptions = [];
        _selectedJamReservasi = null;
      });
      return;
    }

    final hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ][_selectedTanggal!.weekday % 7];

    final dokter = _allDokterList.firstWhere(
      (d) => d['IDDOKTER'] == _selectedDokterId,
      orElse: () => {},
    );

    if (dokter.isNotEmpty && dokter['JADWALPRAKTEK'] != null) {
      final List<String> jadwal = dokter['JADWALPRAKTEK'];
      setState(() {
        _jamOptions = jadwal
            .where((j) => j.toLowerCase().contains(hari.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _editReservasi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPoliId == null ||
        _selectedDokterId == null ||
        _selectedTanggal == null ||
        _selectedJamReservasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _reservasiService.editReservasi(
        idReservasi: widget.reservasi.idReservasi,
        idPoli: _selectedPoliId!,
        idDokter: _selectedDokterId!,
        tanggalReservasi: DateTime(
          _selectedTanggal!.year,
          _selectedTanggal!.month,
          _selectedTanggal!.day,
        ).add(const Duration(days: 1)).toUtc().toIso8601String().split('T')[0],
        jamReservasi: _selectedJamReservasi!,
        keterangan: _keteranganController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservasi berhasil diubah')),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah reservasi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomTopBar(title: 'Edit Reservasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    // 📅 Tanggal Reservasi
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Reservasi',
                        prefixIcon: const Icon(Icons.date_range),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          initialDate: _selectedTanggal ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedTanggal = pickedDate;
                            _selectedDokterId = null;
                            _selectedJamReservasi = null;
                            _filterDokterByPoliAndTanggal();
                            _filterJamReservasi();
                          });
                        }
                      },
                      validator: (value) =>
                          _selectedTanggal == null ? '' : null,
                    ),
                    const SizedBox(height: 16),

                    // 🏥 Pilih Poli
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Poli',
                        prefixIcon: const Icon(Icons.local_hospital),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedPoliId,
                      items: _poliList.map((poli) {
                        return DropdownMenuItem<int>(
                          value: poli['IDPOLI'],
                          child: Text(poli['NAMAPOLI'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPoliId = value;
                          _selectedDokterId = null;
                          _selectedJamReservasi = null;
                          _filterDokterByPoliAndTanggal();
                          _filterJamReservasi();
                        });
                      },
                      validator: (value) => value == null ? '' : null,
                    ),
                    const SizedBox(height: 16),

                    // 👨‍⚕️ Pilih Dokter
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Dokter',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedDokterId,
                      items: _dokterList.map((d) {
                        return DropdownMenuItem<int>(
                          value: d['IDDOKTER'],
                          child: Text(d['NAMALENGKAP'] ?? '-'),
                        );
                      }).toList(),
                      onChanged:
                          (_selectedPoliId == null || _selectedTanggal == null)
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedDokterId = value;
                                    _selectedJamReservasi = null;
                                    _filterJamReservasi();
                                  });
                                },
                      validator: (value) => value == null ? '' : null,
                    ),
                    const SizedBox(height: 16),

                    // ⏰ Pilih Jam
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Jam Praktek',
                        prefixIcon: const Icon(Icons.access_time),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedJamReservasi,
                      items: _jamOptions.map((jam) {
                        return DropdownMenuItem<String>(
                          value: jam,
                          child: Text(jam),
                        );
                      }).toList(),
                      onChanged: (_selectedDokterId == null)
                          ? null
                          : (value) {
                              setState(() {
                                _selectedJamReservasi = value;
                              });
                            },
                      validator: (value) => value == null ? '' : null,
                    ),
                    const SizedBox(height: 16),

                    // 📝 Keterangan
                    TextFormField(
                      controller: _keteranganController,
                      decoration: InputDecoration(
                        labelText: 'Keterangan (Opsional)',
                        prefixIcon:
                            const Icon(Icons.note_alt_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // 🔘 Tombol Edit
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.lightBlue,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _editReservasi,
                              icon: const Icon(Icons.edit),
                              label: const Text(
                                'Edit Reservasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                            ),
                    ),

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
          ),
        ),
      ),
    );
  }
}
