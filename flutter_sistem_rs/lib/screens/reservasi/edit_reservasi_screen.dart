import 'package:flutter/material.dart';
import '../../services/reservasi_service.dart';
import '../../models/reservasi_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import '../../widgets/custom_topbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  
  // Tambahan untuk jumlah reservasi
  int? _jumlahReservasi;
  bool _isLoadingJumlah = false;

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
      _cekJumlahReservasi();
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

  // Method untuk mengecek jumlah reservasi
  Future<void> _cekJumlahReservasi() async {
    if (_selectedDokterId == null || _selectedTanggal == null) {
      setState(() {
        _jumlahReservasi = null;
      });
      return;
    }

    setState(() {
      _isLoadingJumlah = true;
    });

    try {
      final tanggalReservasi = DateTime(
        _selectedTanggal!.year,
        _selectedTanggal!.month,
        _selectedTanggal!.day,
      ).add(const Duration(days: 1)).toUtc().toIso8601String().split('T')[0];

      final jumlah = await _reservasiService.getJumlahReservasi(
        idDokter: _selectedDokterId!,
        tanggalReservasi: tanggalReservasi,
      );

      setState(() {
        _jumlahReservasi = jumlah;
        _isLoadingJumlah = false;
      });
    } catch (e) {
      setState(() {
        _jumlahReservasi = null;
        _isLoadingJumlah = false;
      });
    }
  }

  Future<void> _editReservasi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPoliId == null ||
        _selectedDokterId == null ||
        _selectedTanggal == null ||
        _selectedJamReservasi == null) {
      Fluttertoast.showToast(
        msg: 'Harap lengkapi semua data.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 14,
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
      Fluttertoast.showToast(
        msg: "Reservasi berhasil disimpan!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      Fluttertoast.showToast(
        msg: 'Gagal mengubah reservasi.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(title: 'Edit Reservasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_calendar,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Reservasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 20),

                  // 📅 Tanggal Reservasi
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Reservasi',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.date_range, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedTanggal = pickedDate;
                          _selectedDokterId = null;
                          _selectedJamReservasi = null;
                          _jumlahReservasi = null;
                          _filterDokterByPoliAndTanggal();
                          _filterJamReservasi();
                        });
                      }
                    },
                    validator: (value) => _selectedTanggal == null ? 'Pilih tanggal' : null,
                  ),
                  const SizedBox(height: 16),

                  // 🏥 Pilih Poli
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Pilih Poli',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.local_hospital, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                        _jumlahReservasi = null;
                        _filterDokterByPoliAndTanggal();
                        _filterJamReservasi();
                      });
                    },
                    validator: (value) => value == null ? 'Pilih poli' : null,
                  ),
                  const SizedBox(height: 16),

                  // 👨‍⚕️ Pilih Dokter
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Pilih Dokter',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                      ),
                    ),
                    value: _selectedDokterId,
                    items: _dokterList.map((d) {
                      return DropdownMenuItem<int>(
                        value: d['IDDOKTER'],
                        child: Text(d['NAMALENGKAP'] ?? '-'),
                      );
                    }).toList(),
                    onChanged: (_selectedPoliId == null || _selectedTanggal == null)
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDokterId = value;
                              _selectedJamReservasi = null;
                              _filterJamReservasi();
                              _cekJumlahReservasi();
                            });
                          },
                    validator: (value) => value == null ? 'Pilih dokter' : null,
                  ),
                  const SizedBox(height: 16),

                  // Info Jumlah Reservasi
                  if (_selectedDokterId != null && _selectedTanggal != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isLoadingJumlah
                                ? const Text(
                                    'Mengecek jumlah antrian...',
                                    style: TextStyle(fontSize: 13),
                                  )
                                : Text(
                                    _jumlahReservasi != null
                                        ? 'Saat ini ada $_jumlahReservasi reservasi pada dokter dan tanggal yang sama'
                                        : 'Gagal mengecek jumlah reservasi',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedDokterId != null && _selectedTanggal != null)
                    const SizedBox(height: 16),

                  // ⏰ Pilih Jam
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pilih Jam Praktek',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.access_time, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                    validator: (value) => value == null ? 'Pilih jam praktek' : null,
                  ),
                  const SizedBox(height: 16),

                  // 📝 Keterangan
                  TextFormField(
                    controller: _keteranganController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan (Opsional)',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.note_alt_outlined, color: Colors.blue.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                              color: Colors.blue,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _editReservasi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}