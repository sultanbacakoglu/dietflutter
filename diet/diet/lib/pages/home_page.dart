import 'package:diet/pages/diet_list_page.dart';
import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../pages/patients.dart';
import '../pages/dashboard.dart';
import '../pages/appointments_page.dart'; // Randevular sayfası importu
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    AppointmentsPage(),
    DietListPage(),
    ClientsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
