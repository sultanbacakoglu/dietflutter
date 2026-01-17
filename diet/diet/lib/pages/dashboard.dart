import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/user_header.dart';
import '../components/search_bar.dart';
import '../services/client_service.dart';
import '../services/appointment_service.dart';
import 'add_client_page.dart';
import 'add_appointment_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ClientService _clientService = ClientService();
  final AppointmentService _apptService = AppointmentService();

  int _clientCount = 0;
  int _todayApptCount = 0;
  Map<String, dynamic>? _nextAppointment;
  List<dynamic> _recentClients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final clients = await _clientService.getClients();
      final appointments = await _apptService.getAppointments();

      final now = DateTime.now();

      final todayAppts = appointments.where((a) {
        final date = DateTime.parse(a['startDate']);
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();

      final futureAppts = appointments.where((a) {
        final date = DateTime.parse(a['startDate']);
        return date.isAfter(now);
      }).toList();

      futureAppts.sort((a, b) => DateTime.parse(a['startDate'])
          .compareTo(DateTime.parse(b['startDate'])));

      if (mounted) {
        setState(() {
          _clientCount = clients.length;
          _recentClients = clients.take(5).toList();
          _todayApptCount = todayAppts.length;
          _nextAppointment = futureAppts.isNotEmpty ? futureAppts.first : null;
        });
      }
    } catch (e) {
      print("Veri yükleme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const UserHeader(),
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchBarWidget(),
              const SizedBox(height: 24),
              const Text("Günlük Özet",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatCard(
                    title: "Toplam Danışan",
                    value: _clientCount.toString(),
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF6366F1),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: "Bugünkü Randevu",
                    value: _todayApptCount.toString(),
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Sıradaki Randevu",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              _nextAppointment == null
                  ? _buildEmptyState()
                  : _buildNextAppointmentCard(_nextAppointment!),
              const SizedBox(height: 30),
              const Text("Hızlı İşlemler",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                        Icons.person_add, "Danışan\nEkle", Colors.blue,
                        () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddClientPage()));
                      _loadData();
                    }),
                  ),
                  const SizedBox(width: 16),

                  // GÜNCELLEME BURADA: Artık yeni sayfaya yönlendiriyor
                  Expanded(
                    child: _buildQuickAction(Icons.add_task, "Randevu\nOluştur",
                        const Color(0xFF382aae), () async {
                      // Pop-up yerine yeni sayfayı açıyoruz
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AddAppointmentPage()));

                      // Eğer randevu eklenip dönüldüyse (result == true), verileri yenile
                      if (result == true) {
                        _loadData();
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextAppointmentCard(Map<String, dynamic> appt) {
    DateTime date = DateTime.parse(appt['startDate']);
    String time = DateFormat('HH:mm').format(date);
    String day = DateFormat('d MMMM', 'tr_TR').format(date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF382aae), Color(0xFF5E54E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF382aae).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Yaklaşan Randevu",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(appt['title'] ?? "İsimsiz",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text("$day, $time",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("Sırada bekleyen randevu yok",
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bgColor.withOpacity(1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
