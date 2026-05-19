import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';

void main() async {
  // Pastikan inisialisasi Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Memulai koneksi ke Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
