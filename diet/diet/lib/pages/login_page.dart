import 'package:diet/components/custom_text_field.dart';
import 'package:diet/components/navbar.dart';
import 'package:diet/components/primary_button.dart';
import 'package:diet/pages/home_page.dart';
import 'package:diet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
// import 'home_screen.dart'; // Kendi ana sayfanı buraya import etmelisin

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'username', response['Username'] ?? _usernameController.text);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety,
                size: 80, color: Color(0xFF382aae)),
            const SizedBox(height: 20),
            const Text("Klinik Yönetim",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382aae))),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _usernameController,
              hintText: 'Kullanıcı Adı',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Şifre',
              obscureText: true,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : PrimaryButton(
                    text: 'Giriş Yap',
                    onPressed: _handleLogin,
                  ),
          ],
        ),
      ),
    );
  }
}
