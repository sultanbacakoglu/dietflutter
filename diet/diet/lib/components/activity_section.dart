import 'package:flutter/material.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Appointments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        // Örnek randevu listesi
        AppointmentItem(
          time: '12:10 pm - 1:00 pm',
          patientName: 'Mia Collins',
          description: 'Routine checkup',
          backgroundColor: Color.fromARGB(30, 255, 165, 0),
        ),
        SizedBox(height: 8),
        AppointmentItem(
          time: '2:00 pm - 2:30 pm',
          patientName: 'John Doe',
          description: 'Diet consultation',
          backgroundColor: Color.fromARGB(30, 255, 165, 0),
        ),
        SizedBox(height: 8),
        AppointmentItem(
          time: '3:00 pm - 3:45 pm',
          patientName: 'Emma Smith',
          description: 'Follow-up session',
          backgroundColor: Color.fromARGB(30, 255, 165, 0),
        ),
      ],
    );
  }
}

class AppointmentItem extends StatelessWidget {
  final String time;
  final String patientName;
  final String description;
  final Color backgroundColor;

  const AppointmentItem({
    super.key,
    required this.time,
    required this.patientName,
    required this.description,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(patientName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
