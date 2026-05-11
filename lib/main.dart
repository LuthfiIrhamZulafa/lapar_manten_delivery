import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';

void main() async {
  // Pastikan inisialisasi Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Memulai koneksi ke Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapar Manten Delivery',
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan DEBUG
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red, // Sesuaikan dengan aksen merah logo kamu
        ),
        useMaterial3: true,
      ),

      // DISINI KUNCINYA:
      // Halaman yang pertama kali dijalankan adalah SplashScreen
      home: const SplashScreen(),
    );
  }
}
