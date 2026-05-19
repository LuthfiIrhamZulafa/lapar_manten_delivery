import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- BERGANTI KE SUPABASE

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

  // FUNGSI SIMPAN PROFIL KE SUPABASE DATABASE TABLE
  Future<void> simpanProfilUser(
    String uid,
    String nama,
    String noHp,
    String alamat,
    String email,
  ) async {
    await Supabase.instance.client.from('users').insert({
      'id': uid, // ID disamakan dengan ID Autentikasi Supabase agar sinkron
      'nama_lengkap': nama,
      'nomor_hp': noHp,
      'alamat_default': alamat,
      'email': email,
    });
  }

  // FUNGSI DAFTAR AKUN KE SUPABASE AUTH
  Future<void> _daftar() async {
    // Validasi input sederhana agar tidak mengirim data kosong ke database
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Kata Sandi tidak boleh kosong"),
        ),
      );
      return;
    }

    try {
      // Menampilkan loading indikator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Proses Registrasi Email & Password di Supabase Auth
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Jika pembuatan user auth berhasil, lanjut simpan data profil ke tabel 'users'
      if (response.user != null) {
        await simpanProfilUser(
          response.user!.id, // Mengambil UID unik dari Supabase Auth
          _namaController.text.trim(),
          _noHpController.text.trim(),
          _alamatController.text.trim(),
          _emailController.text.trim(),
        );

        if (mounted) Navigator.pop(context); // Tutup loading dialog
        print("Akun dan Profil Berhasil Dibuat di Supabase!");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registrasi Berhasil! Silakan masuk."),
            ),
          );
          // Kembali ke halaman sebelumnya (biasanya halaman Login)
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted)
        Navigator.pop(context); // Tutup loading dialog jika terjadi kegagalan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Daftar: ${e.toString()}")),
        );
      }
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
              // Logo Pudar di Bawah tetap dipertahankan aman
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
