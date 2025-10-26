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
    return DateTime(date.year, date.month, date.day);
  }

  List<Kalender> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showKalenderDialog(List<Kalender> kalenders, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Kalender Dokter ${date.day}/${date.month}/${date.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kalenders.length,
              itemBuilder: (context, index) {
                final k = kalenders[index];
                return Card(
                  color: k.isLibur ? Colors.red[50] : Colors.blue[50],
                  child: ListTile(
                    title: Text(k.namaDokter ?? 'Dokter tidak diketahui'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${k.status}'),
                        if (k.keterangan != null)
                          Text('Keterangan: ${k.keterangan}'),
                      ],
                    ),
                    leading: Icon(
                      Icons.account_circle,
                      color: k.isLibur ? Colors.red : Colors.blue,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
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
      appBar: CustomTopBar(
        title: 'Kalender Dokter',
      ),
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

            for (var item in data) {
              final date = _normalizeDate(item.tanggal);
              events.putIfAbsent(date, () => []).add(item);
              if (item.isLibur) liburList.add(item);
            }

            _events = events;
            _liburList = liburList;

            final currentMonthLibur = _liburList.where((item) {
              final date = _normalizeDate(item.tanggal);
              return date.month == _focusedDay.month &&
                  date.year == _focusedDay.year;
            }).toList();

            return Column(
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
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  // 🔹 Hilangkan titik kecil bawaan TableCalendar
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 0, // ⛔️ tidak tampilkan marker apapun
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 🔹 Indikator merah di tanggal libur
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final isLibur = _liburList.any((item) {
                        final liburDate = _normalizeDate(item.tanggal);
                        return liburDate.year == day.year &&
                            liburDate.month == day.month &&
                            liburDate.day == day.day;
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
                      }

                      return null;
                    },
                  ),
                ),

                if (currentMonthLibur.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text(
                    '📅 Jadwal Libur Dokter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentMonthLibur.length,
                      itemBuilder: (context, index) {
                        final item = currentMonthLibur[index];
                        final date = _normalizeDate(item.tanggal);
                        return ListTile(
                          leading:
                              const Icon(Icons.event_busy, color: Colors.red),
                          title:
                              Text(item.namaDokter ?? 'Dokter tidak diketahui'),
                          subtitle: Text(_formatTanggal(date)),
                          trailing: Text(
                            item.keterangan ?? '',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Tidak ada dokter yang libur bulan ini.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            );
          }

          return const Center(child: Text('Tidak ada data kalender'));
        },
      ),
    );
  }
}
