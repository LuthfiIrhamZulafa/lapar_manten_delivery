import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color warnaMerahUtama = const Color(0xFFC60D2A);

  Future<void> simpanProfilUser(String nama, String noHp, String alamat) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nama_lengkap': nama,
        'nomor_hp': noHp,
        'alamat_default': alamat,
        'email': FirebaseAuth.instance.currentUser?.email,
        'created_at': DateTime.now(),
      });
    }
  }

  Future<void> _daftar() async {
    try {
      // Menampilkan loading indikator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await simpanProfilUser(
          _namaController.text.trim(),
          _noHpController.text.trim(),
          _alamatController.text.trim(),
        );

        Navigator.pop(context); // Tutup loading
        print("Akun dan Profil Berhasil Dibuat!");

        // Pindah ke halaman login atau home setelah sukses
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal Daftar: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "LAPAR MANTEN",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Daftar Akun Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                "Nama Lengkap",
                _namaController,
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Nomor Telepon",
                _noHpController,
                Icons.phone_android,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Alamat",
                _alamatController,
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, Icons.alternate_email),
              const SizedBox(height: 16),
              _buildTextField(
                "Kata Sandi",
                _passwordController,
                Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _daftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warnaMerahUtama,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Daftar Sekarang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Logo Pudar di Bawah
              Image.asset(
                'assets/images/logo_garpuh.png',
                width: 60,
                opacity: const AlwaysStoppedAnimation(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }
}
