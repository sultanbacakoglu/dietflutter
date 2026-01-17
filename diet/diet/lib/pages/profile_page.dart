import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;

  void _handleChangePassword() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Yeni şifreler uyuşmuyor"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.changePassword(
          _currentController.text, _newController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Şifre başarıyla güncellendi!"),
          backgroundColor: Colors.green));
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hesap Ayarları",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                    "Kullanıcı adı değiştirilemez, sadece şifrenizi güncelleyebilirsiniz.",
                    style: TextStyle(color: Colors.orange.shade900),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Şifre ve Güvenlik",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382aae))),
            const SizedBox(height: 20),
            CustomTextField(
                controller: _currentController,
                hintText: "Mevcut Şifre",
                obscureText: true),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _newController,
                hintText: "Yeni Şifre",
                obscureText: true),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _confirmController,
                hintText: "Yeni Şifre (Tekrar)",
                obscureText: true),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: "Şifreyi Güncelle", onPressed: _handleChangePassword),
          ],
        ),
      ),
    );
  }
}
