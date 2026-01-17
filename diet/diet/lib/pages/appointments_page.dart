import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import 'add_appointment_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentService _apptService = AppointmentService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _appointments = {};
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF382aae);
  final List<Color> _colors = [
    const Color(0xFF382aae),
    const Color(0xFF10b981),
    const Color(0xFFf59e0b),
    const Color(0xFFef4444),
    const Color(0xFF06b6d4),
    const Color(0xFF8b5cf6)
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  void _loadAppointments() async {
    try {
      final data = await _apptService.getAppointments();
      final Map<DateTime, List<dynamic>> mappedData = {};

      for (var item in data) {
        final date = DateTime.parse(item['startDate']);
        final keyDate = DateTime.utc(date.year, date.month, date.day);

        if (mappedData[keyDate] == null) mappedData[keyDate] = [];
        mappedData[keyDate]!.add(item);
      }

      setState(() {
        _appointments = mappedData;
        _isLoading = false;
      });
    } catch (e) {
      print("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _appointments[DateTime.utc(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ??
        [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Randevu Takvimi",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAppointmentPage()),
          );

          if (result == true) {
            _loadAppointments();
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'tr_TR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) =>
                _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5), shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: primaryColor, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 50, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text("Bu tarih için randevu yok",
                                style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final appt = selectedEvents[index];
                          final color = _colors[
                              (appt['appointmentId'] ?? 0) % _colors.length];
                          final date = DateTime.parse(appt['startDate']);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.05),
                                border: Border(
                                    left: BorderSide(color: color, width: 4)),
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(appt['title'] ?? "İsimsiz",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                      "${DateFormat('HH:mm').format(date)} - ${appt['typeDescription'] ?? 'Genel'}"),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("Aktif",
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
