import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/kalender_model.dart';
import '../../services/kalender_service.dart';
import '../../widgets/custom_topbar.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  late Future<List<Kalender>> _futureKalender;
  Map<DateTime, List<Kalender>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureKalender = KalenderService.fetchKalender();
  }

  /// 🔹 Mengonversi string tanggal menjadi DateTime tanpa waktu
  DateTime _normalizeDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return DateTime.now();
    return DateTime(date.year, date.month, date.day);
  }

  /// 🔹 Mendapatkan event berdasarkan tanggal
  List<Kalender> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// 🔹 Menampilkan dialog detail kalender
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
                      color: k.isLibur ? Colors.black : Colors.black,
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

            // 🚀 Proses data tanpa setState
            final Map<DateTime, List<Kalender>> events = {};
            for (var item in data) {
              final date = _normalizeDate(item.tanggal);
              events.putIfAbsent(date, () => []).add(item);
            }

            _events = events;

            return TableCalendar<Kalender>(
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
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
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
              ),
            );
          }

          return const Center(child: Text('Tidak ada data kalender'));
        },
      ),
    );
  }
}
