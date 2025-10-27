import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/kalender_model.dart';
import '../../services/kalender_service.dart';
import '../../widgets/custom_topbar.dart';
import 'package:intl/intl.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  late Future<List<Kalender>> _futureKalender;
  Map<DateTime, List<Kalender>> _events = {};
  List<Kalender> _liburList = [];
  List<Kalender> _perjanjianList = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureKalender = KalenderService.fetchKalender();
  }

  DateTime _normalizeDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return DateTime.now();

    final localDate = date.toLocal(); // pastikan tanggal lokal
    return DateTime(localDate.year, localDate.month, localDate.day);
  }

  List<Kalender> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showKalenderDialog(List<Kalender> kalenders, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Kalender Dokter (${DateFormat('dd MMMM yyyy', 'id_ID').format(date)})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kalenders.length,
              itemBuilder: (context, index) {
                final k = kalenders[index];
                final isPerjanjian = k.status.toLowerCase() == 'perjanjian';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: k.isLibur
                        ? Colors.red[50]
                        : isPerjanjian
                            ? Colors.blue[50]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: k.isLibur
                          ? Colors.red.shade200
                          : isPerjanjian
                              ? Colors.blue.shade200
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: k.isLibur
                          ? Colors.red.shade100
                          : isPerjanjian
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: k.isLibur
                            ? Colors.red
                            : isPerjanjian
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ),
                    title: Text(
                      k.namaDokter ?? 'Dokter tidak diketahui',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${k.status}', style: const TextStyle(fontSize: 13)),
                        if (k.keterangan != null)
                          Text(
                            'Keterangan: ${k.keterangan}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  String _formatTanggal(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(title: 'Kalender Dokter'),
      body: FutureBuilder<List<Kalender>>(
        future: _futureKalender,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;
            final Map<DateTime, List<Kalender>> events = {};
            final List<Kalender> liburList = [];
            final List<Kalender> perjanjianList = [];

            for (var item in data) {
              final date = _normalizeDate(item.tanggal);
              events.putIfAbsent(date, () => []).add(item);

              if (item.isLibur) {
                liburList.add(item);
              } else if (item.status.toLowerCase() == 'perjanjian') {
                perjanjianList.add(item);
              }
            }

            _events = events;
            _liburList = liburList;
            _perjanjianList = perjanjianList;

            final currentMonthLibur = _liburList.where((item) {
              final date = _normalizeDate(item.tanggal);
              return date.month == _focusedDay.month && date.year == _focusedDay.year;
            }).toList();

            final currentMonthPerjanjian = _perjanjianList.where((item) {
              final date = _normalizeDate(item.tanggal);
              return date.month == _focusedDay.month && date.year == _focusedDay.year;
            }).toList();

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  TableCalendar<Kalender>(
                    locale: 'id_ID',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    eventLoader: (day) => _getEventsForDay(day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      final kalenderList = _getEventsForDay(selectedDay);
                      if (kalenderList.isNotEmpty) {
                        _showKalenderDialog(kalenderList, selectedDay);
                      }
                    },
                    onPageChanged: (focusedDay) {
                      setState(() => _focusedDay = focusedDay);
                    },
                    calendarStyle: CalendarStyle(
                      markersMaxCount: 0,
                      todayDecoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.redAccent),
                      defaultTextStyle: const TextStyle(fontSize: 14),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final isLibur = _liburList.any((item) {
                          final liburDate = _normalizeDate(item.tanggal);
                          return liburDate.year == day.year &&
                              liburDate.month == day.month &&
                              liburDate.day == day.day;
                        });

                        final isPerjanjian = _perjanjianList.any((item) {
                          final perjanjianDate = _normalizeDate(item.tanggal);
                          return perjanjianDate.year == day.year &&
                              perjanjianDate.month == day.month &&
                              perjanjianDate.day == day.day;
                        });

                        if (isLibur) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else if (isPerjanjian) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Daftar jadwal libur dan perjanjian
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentMonthLibur.isNotEmpty) ...[
                            const Text(
                              '📅 Jadwal Libur Dokter Bulan Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...currentMonthLibur.map((item) {
                              final date = _normalizeDate(item.tanggal);
                              return ListTile(
                                leading: const Icon(Icons.event_busy, color: Colors.red),
                                title: Text(item.namaDokter ?? 'Dokter tidak diketahui'),
                                subtitle: Text(_formatTanggal(date)),
                                trailing: Text(
                                  item.keterangan ?? '',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              );
                            }),
                            const Divider(),
                          ],
                          if (currentMonthPerjanjian.isNotEmpty) ...[
                            const Text(
                              '📘 Jadwal Perjanjian Dokter Bulan Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...currentMonthPerjanjian.map((item) {
                              final date = _normalizeDate(item.tanggal);
                              return ListTile(
                                leading: const Icon(Icons.event_note, color: Colors.blue),
                                title: Text(item.namaDokter ?? 'Dokter tidak diketahui'),
                                subtitle: Text(_formatTanggal(date)),
                                trailing: Text(
                                  item.keterangan ?? '',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              );
                            }),
                          ],
                          if (currentMonthLibur.isEmpty && currentMonthPerjanjian.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Tidak ada jadwal libur atau perjanjian bulan ini.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Tidak ada data kalender'));
        },
      ),
    );
  }
}
