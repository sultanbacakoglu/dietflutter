import 'package:flutter/material.dart';
import '../components/navbar.dart';

import 'dashboard.dart';
import 'appointments_page.dart';
import 'diet_list_page.dart';
import 'patients.dart';
import 'profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(), // 0: Ana Sayfa
    const AppointmentsPage(), // 1: Randevular
    const DietListPage(), // 2: Diyetler
    const ClientsPage(), // 3: Danışanlar
    const ProfilePage(), // 4: Profilim
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
