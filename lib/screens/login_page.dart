import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obsecurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Warna Merah Utama sesuai desain kamu
  final Color warnaMerahUtama = const Color(0xFFC60D2A);

  // --- FUNGSI LOGIN MANUAL ---
  Future<void> _login() async {
    try {
      _showLoadingDialog();

      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Menutup loading
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar(_getErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      print(e.toString());
    }
  }

  // --- FUNGSI LOGIN GOOGLE (AUTO-REGISTER) ---
  Future<void> _loginGoogle() async {
    try {
      _showLoadingDialog();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pop(context);
      _navigateToHome();
    } catch (e) {
      if (mounted) Navigator.pop(context);

      _showErrorSnackBar("Gagal login Google: $e");
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
    // TODO: Ganti ke halaman HomePage kamu
    print("Navigasi ke Home...");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false, // Ini penting agar user tidak bisa 'back' ke login lagi
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

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return "Email tidak terdaftar.";
      case 'wrong-password':
        return "Kata sandi salah.";
      case 'invalid-credential':
        return "Email atau kata sandi salah.";
      case 'user-disabled':
        return "Akun ini telah dinonaktifkan.";
      default:
        return "Terjadi kesalahan.";
    }
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
                      SizedBox(width: 10),
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

              // Bagian Tombol Google (Facebook dihapus, posisi di tengah)
              Center(
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.7, // Mengatur lebar tombol agar tidak terlalu lebar
                  child: _buildSocialButton(
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
