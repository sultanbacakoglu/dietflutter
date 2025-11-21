import 'package:flutter/material.dart';
import '../components/user_header.dart';
import '../components/search_bar.dart';
import '../components/activity_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const UserHeader(),
        toolbarHeight: 80,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 10),
              SearchBarWidget(),
              SizedBox(height: 20),
              ActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}
