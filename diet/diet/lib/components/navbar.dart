import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final Color primaryColor = const Color(0xFF382aae);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        iconSize: 26,
        items: [
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 1
                ? Icons.calendar_month
                : Icons.calendar_month_outlined),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 2
                ? Icons.restaurant_menu
                : Icons.restaurant_menu_outlined),
            label: 'Diyetler',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(currentIndex == 3 ? Icons.groups : Icons.groups_outlined),
            label: 'Danışanlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 4 ? Icons.person : Icons.person_outline),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}
