import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';

class TodayAppointments extends StatefulWidget {
  const TodayAppointments({super.key});

  @override
  State<TodayAppointments> createState() => _TodayAppointmentsState();
}

class _TodayAppointmentsState extends State<TodayAppointments> {
  final AppointmentService _apptService = AppointmentService();
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _apptService.getAppointments();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bugünkü Randevular',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF382aae)),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text("Hata: {snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            List<dynamic> allAppointments = snapshot.data!;

            List<dynamic> todayAppointments = allAppointments.where((appt) {
              DateTime apptDate = DateTime.parse(appt['startDate']);
              return isSameDay(apptDate, DateTime.now());
            }).toList();

            todayAppointments.sort((a, b) {
              DateTime dateA = DateTime.parse(a['startDate']);
              DateTime dateB = DateTime.parse(b['startDate']);
              return dateA.compareTo(dateB);
            });

            if (todayAppointments.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                var appt = todayAppointments[index];
                return _buildAppointmentCard(appt);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Bugün için planlanmış randevunuz bulunmuyor. Günü kendinize ayırabilirsiniz! ☕",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appt) {
    DateTime startDate = DateTime.parse(appt['startDate']);
    DateTime endDate = DateTime.parse(appt['endDate']);
    String timeStr =
        "{DateFormat('HH:mm').format(startDate)} - {DateFormat('HH:mm').format(endDate)}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
            left: BorderSide(
                color: _getColorByType(appt['appointmentTypeId']), width: 5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF382aae)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt['title'] ?? "İsimsiz Danışan",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getColorByType(appt['appointmentTypeId'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appt['typeDescription'] ?? "Genel",
                        style: TextStyle(
                            fontSize: 10,
                            color: _getColorByType(appt['appointmentTypeId']),
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorByType(int? typeId) {
    switch (typeId) {
      case 1:
        return const Color(0xFF382aae);
      case 2:
        return const Color(0xFF10b981);
      case 3:
        return const Color(0xFFf59e0b);
      default:
        return Colors.grey;
    }
  }
}
