import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool _isLoading = true;
 bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // FUNGSI MENGAMBIL DATA PROFIL DARI SUPABASE
  Future<void> _getProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error ambil profil: $e");
      setState(() => _isLoading = false);
    }
  }

  // FUNGSI LOGOUT
  // FUNGSI LOGOUT
Future<void> _handleLogout() async {
  // Tampilkan konfirmasi sebelum keluar
  final bool? setujuKeluar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          "Keluar dari Akun",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar dari akun?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFC60D2A),
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Keluar",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (setujuKeluar != true || !mounted) {
    return;
  }

  setState(() {
    _isLoggingOut = true;
  });

  try {
    // Keluar dari akun Supabase
    await _supabase.auth.signOut();

    // Hapus status login lokal
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isLoggedIn',
      false,
    );

    if (!mounted) return;

    // Hapus semua riwayat halaman dan kembali ke Login
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoggingOut = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Gagal keluar dari akun: $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final userAktif = Supabase.instance.client.auth.currentUser;
    final String namaTampil =
        userData?['nama_lengkap'] ??
        userAktif?.userMetadata?['full_name'] ??
        (userAktif?.email != null
            ? userAktif!.email!.split('@')[0]
            : "Pengguna Lapar Manten");
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "PROFIL",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC60D2A)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER PROFIL ---
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // FOTO PROFIL
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF5F5F5),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFFC60D2A),
                              ),
                            ),

                            // TOMBOL EDIT
                            // TOMBOL EDIT
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  _tampilkanDialogEditNama(namaTampil);
                                },
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFC60D2A),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // NAMA USER
                        Text(
                          namaTampil,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // EMAIL USER
                        Text(
                          userData?['email'] ?? userAktif?.email ?? "-",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        // --- TOMBOL KHUSUS ADMIN ---
                        if (userAktif?.email == 'laparmanten09@gmail.com') ...[
                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminOrdersPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.dashboard_customize,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "MENU PANTAU PESANAN (ADMIN)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB71C1C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // --- MENU AKUN SAYA ---
                  _buildSectionTitle("AKUN SAYA"),
                  _buildMenuItem(
                    Icons.person_outline,
                    "Edit Profil",
                    const Color(0xFFFDE8E8),
                  ),
                  _buildMenuItem(
                    Icons.location_on_outlined,
                    "Alamat Tersimpan",
                    const Color(0xFFFDE8E8),
                  ),
                  _buildMenuItem(
                    Icons.credit_card_outlined,
                    "Metode Pembayaran",
                    const Color(0xFFFDE8E8),
                  ),

                  // --- MENU LAINNYA ---
                  _buildSectionTitle("LAINNYA"),
                  _buildMenuItem(
                    Icons.help_outline,
                    "Pusat Bantuan",
                    Colors.grey[100]!,
                  ),
                  _buildMenuItem(
                    Icons.description_outlined,
                    "Syarat & Ketentuan",
                    Colors.grey[100]!,
                  ),
                  _buildMenuItem(
                    Icons.shield_outlined,
                    "Kebijakan Privasi",
                    Colors.grey[100]!,
                  ),

                  const SizedBox(height: 30),

                  // --- TOMBOL KELUAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
  onPressed:
      _isLoggingOut ? null : _handleLogout,
                        icon: _isLoggingOut
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFC60D2A),
        ),
      )
    : const Icon(
        Icons.logout,
        color: Color(0xFFC60D2A),
      ),
label: Text(
  _isLoggingOut
      ? "Sedang Keluar..."
      : "Keluar",
  style: GoogleFonts.poppins(
    color: const Color(0xFFC60D2A),
    fontWeight: FontWeight.bold,
  ),
),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFFC60D2A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Versi Aplikasi 1.0.0 (Skripsi Build)",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  // FUNGSI UNTUK MENAMPILKAN DIALOG SAAT TOMBOL PENSIL DIPENCET
  void _tampilkanDialogEditNama(String namaSekarang) {
    final TextEditingController _editNamaController = TextEditingController(
      text: namaSekarang,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ubah Nama Profil"),
          content: TextField(
            controller: _editNamaController,
            decoration: const InputDecoration(
              labelText: "Nama Lengkap",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logika simpan perubahan nama ke Supabase bisa kamu taruh di sini nanti
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur edit nama profil berhasil merespons!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC60D2A),
              ),
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // WIDGET JUDUL SECTION
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // WIDGET ITEM MENU
  Widget _buildMenuItem(IconData icon, String title, Color iconBgColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFC60D2A), size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi ke halaman detail jika diperlukan
        },
      ),
    );
  }
}
