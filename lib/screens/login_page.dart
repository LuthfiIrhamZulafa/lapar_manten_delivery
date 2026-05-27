import 'package:flutter/material.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isGoogleLoading = false;
  bool _obsecurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Warna Merah Utama sesuai desain kamu
  final Color warnaMerahUtama = const Color(0xFFC60D2A);

  @override
  void initState() {
    super.initState();

    // =========================================================================
    // SAKLAR OTOMATIS (ANTI-SANGKUT):
    // Memantau status login Supabase di latar belakang secara real-time.
    // Begitu user sukses memilih akun di Chrome ATAU sukses login manual,
    // fungsi inilah yang akan menghentikan loading dan memindahkan layar ke Home.
    // =========================================================================
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // HANYA jalan jika benar-benar baru login
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });

          _navigateToHome();
        }
      }
    });
  }

  // --- FUNGSI LOGIN MANUAL ---
  Future<void> _login() async {
    try {
      _showLoadingDialog();

      // LOGIN SUPABASE
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Catatan: Navigator.pop untuk menutup dialog loading manual dan pindah halaman
      // sekarang dihandle otomatis oleh onAuthStateChange di atas begitu login sukses.
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading jika gagal
      _showErrorSnackBar("Email atau kata sandi salah");
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> _loginGoogle() async {
    try {
      setState(() {
        _isGoogleLoading = true;
      });

      // JANGAN PAKAI AWAIT DAN ALAMAT REDIRECT SUDAH DISESUAIKAN KE LAPAR MANTEN
      Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.laparmanten://login-callback',
      );
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka Google Sign In: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- HELPER FUNCTIONS ---
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _navigateToHome() {
    print("Navigasi ke Home...");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) =>
          false, // Menghapus tumpukan halaman terdahulu agar user tidak bisa klik 'Back' ke menu Login
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "LAPAR MANTEN",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Selamat Datang Kembali",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Silakan masuk untuk melanjutkan\npesanan Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              _buildInputLabel("Email atau Nomor Telepon"),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: _buildInputDecoration(
                  hint: "contoh@email.com",
                  prefixIcon: Icons.alternate_email,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel("Kata Sandi"),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Lupa Sandi?",
                      style: TextStyle(
                        color: warnaMerahUtama,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _passwordController,
                obscureText: _obsecurePassword,
                decoration: _buildInputDecoration(
                  hint: "Masukkan kata sandi",
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obsecurePassword = !_obsecurePassword),
                    icon: Icon(
                      _obsecurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warnaMerahUtama,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Masuk",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "ATAU MASUK DENGAN",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: _isGoogleLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildSocialButton(
                          "Masuk dengan Google",
                          "assets/images/logo_google.png",
                          _loginGoogle,
                        ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Daftar Sekarang",
                      style: TextStyle(
                        color: warnaMerahUtama,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo_garpuh_silang.png',
                width: 60,
                opacity: const AlwaysStoppedAnimation(0.2),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildSocialButton(
    String label,
    String assetPath,
    VoidCallback onTap,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 24,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.error_outline, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
