import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'home_page.dart'; // IMPORT HALAMAN HOME KAMU
import 'package:supabase_flutter/supabase_flutter.dart'; // IMPORT SUPABASE

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Pindah halaman otomatis setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // CEK STATUS LOGO DI SUPABASE (LOGIKA UTAMA)
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Jika user SUDAH login (sesi aktif), langsung tendang ke HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Jika BELUM login, baru lempar ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  // Warna Merah yang senada dengan logo Manten kamu
  final Color warnaMerahManten = const Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Bagian Tengah (Logo & Loading)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menggunakan nama file baru kamu
                Image.asset('assets/images/logo_lapar_manten.png', width: 250),
                const SizedBox(height: 40),

                // Loading Spinner
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(warnaMerahManten),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),

          // 2. Bagian Bawah (Branding)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menggunakan nama file baru kamu
                Image.asset('assets/images/logo_garpuh.png', width: 24),
                const SizedBox(width: 12),
                const Text(
                  "LAPAR MANTEN",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
