import 'package:flutter/material.dart';
// 1. BU SATIRI EKLEYİN:
import 'package:intl/date_symbol_data_local.dart';
import 'pages/login_page.dart';

// 2. Main fonksiyonunu "async" yapın ve içine gerekli kodları ekleyin
void main() async {
  // Flutter motorunun hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Türkçe tarih formatlama verisini yüklüyoruz (tr_TR)
  await initializeDateFormatting('tr_TR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diyetisyen Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Takvim ve tarih işlemlerinde varsayılan dili Türkçe yapalım
        useMaterial3: false, // İsteğe bağlı, tasarım tercihine göre
      ),
      home: const LoginPage(),
    );
  }
}
