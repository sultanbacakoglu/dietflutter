import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  void _handleChangePassword() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Yeni şifreler uyuşmuyor"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.changePassword(
          _currentController.text, _newController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      appBar: AppBar(
          title: Text("Hesap Ayarları"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        "Kullanıcı adı değiştirilemez, sadece şifre güncellenebilir."))
              ]),
            ),
            SizedBox(height: 20),
            Text("Şifre Değiştir",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382aae))),
            SizedBox(height: 15),
            TextField(
                controller: _currentController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mevcut Şifre", border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(
                controller: _newController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Yeni Şifre", border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Yeni Şifre (Tekrar)",
                    border: OutlineInputBorder())),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save, color: Colors.white),
                label: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Kaydet", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF382aae)),
                onPressed: _isLoading ? null : _handleChangePassword,
              ),
            )
          ],
        ),
      ),
    );
  }
}
