import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke HomePage setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
