import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color _primaryRed =
      Color(0xFFC60D2A);

  static const String _adminEmail =
      'laparmanten09@gmail.com';

  static const List<_PrivacySection> _sections = [
    _PrivacySection(
      number: '01',
      icon: Icons.person_outline,
      title: 'Data Akun dan Profil',
      content:
          'Ketika pengguna membuat atau menggunakan akun, aplikasi dapat menyimpan nama lengkap, alamat email, nomor telepon, alamat utama, foto profil, waktu pembuatan akun, dan identitas pengguna dari layanan autentikasi.',
    ),
    _PrivacySection(
      number: '02',
      icon: Icons.receipt_long_outlined,
      title: 'Data Pesanan dan Layanan',
      content:
          'Aplikasi menyimpan informasi yang diperlukan untuk menjalankan layanan, seperti menu, varian, tambahan, jumlah, catatan, jenis layanan, data pengirim atau penerima, alamat penjemputan dan tujuan, patokan alamat, koordinat, jenis paket, jarak, ongkos, metode pembayaran, driver, dan status pesanan.',
    ),
    _PrivacySection(
      number: '03',
      icon: Icons.account_balance_wallet_outlined,
      title: 'Data Pembayaran',
      content:
          'Apabila pengguna memilih transfer, aplikasi menyimpan foto bukti pembayaran dan referensinya pada transaksi terkait agar admin dapat melakukan verifikasi. Aplikasi tidak meminta PIN, kata sandi perbankan, atau kode OTP pengguna.',
    ),
    _PrivacySection(
      number: '04',
      icon: Icons.location_on_outlined,
      title: 'Data Lokasi',
      content:
          'Lokasi perangkat digunakan ketika pengguna menentukan titik penjemputan atau pengantaran, menghitung jarak dan ongkos, serta membantu driver menemukan tujuan. Data yang dapat diproses meliputi latitude, longitude, tingkat akurasi, waktu pemeriksaan, dan detail alamat yang diberikan pengguna.',
    ),
    _PrivacySection(
      number: '05',
      icon: Icons.security_outlined,
      title: 'Pemeriksaan Keamanan Lokasi',
      content:
          'Untuk membantu mencegah manipulasi lokasi, aplikasi dapat memeriksa indikasi Fake GPS atau Mock Location, perpindahan yang tidak wajar, emulator, kondisi keamanan perangkat, serta informasi pendukung lain yang berkaitan dengan validitas lokasi. Hasil pemeriksaan dapat disimpan sebagai riwayat keamanan lokasi.',
    ),
    _PrivacySection(
      number: '06',
      icon: Icons.notifications_none,
      title: 'Token dan Notifikasi',
      content:
          'Aplikasi dapat menyimpan token notifikasi perangkat agar pelanggan menerima pembaruan status pesanan. Token tersebut digunakan untuk mengirim notifikasi ke perangkat yang terhubung dengan akun dan dapat diperbarui atau dihapus ketika pengguna keluar dari akun.',
    ),
    _PrivacySection(
      number: '07',
      icon: Icons.task_alt_outlined,
      title: 'Tujuan Penggunaan Data',
      content:
          'Data digunakan untuk membuat dan mengelola akun, memproses pesanan, menghitung ongkos, memverifikasi pembayaran, menentukan lokasi, meneruskan informasi kepada driver, menampilkan riwayat, mengirim pembaruan status, mencegah penyalahgunaan, menangani bantuan pengguna, dan meningkatkan layanan.',
    ),
    _PrivacySection(
      number: '08',
      icon: Icons.share_outlined,
      title: 'Informasi yang Diteruskan',
      content:
          'Admin dapat melihat data transaksi untuk memproses pesanan. Driver menerima informasi yang diperlukan untuk menjalankan tugas, seperti nama, nomor telepon, rincian pesanan atau paket, alamat, patokan, dan tautan lokasi. Bukti transfer digunakan oleh admin untuk verifikasi dan tidak perlu diteruskan kepada driver.',
    ),
    _PrivacySection(
      number: '09',
      icon: Icons.cloud_outlined,
      title: 'Layanan Pendukung',
      content:
          'Aplikasi menggunakan layanan pendukung seperti Supabase untuk autentikasi, basis data, dan penyimpanan berkas; Firebase Cloud Messaging untuk notifikasi; OpenStreetMap dan layanan pemetaan atau rute untuk lokasi; serta WhatsApp Deep Linking untuk menyiapkan informasi pesanan yang akan dikirim admin kepada driver.',
    ),
    _PrivacySection(
      number: '10',
      icon: Icons.sell_outlined,
      title: 'Penjualan dan Penggunaan Komersial Data',
      content:
          'Lapar Manten Delivery tidak memperjualbelikan data pribadi pelanggan. Data hanya digunakan untuk kebutuhan operasional, keamanan, dokumentasi transaksi, bantuan pengguna, dan pengembangan layanan sebagaimana dijelaskan pada kebijakan ini.',
    ),
    _PrivacySection(
      number: '11',
      icon: Icons.schedule_outlined,
      title: 'Penyimpanan Data',
      content:
          'Data disimpan selama masih diperlukan untuk menyediakan layanan, menampilkan riwayat transaksi, menangani perselisihan, menjaga keamanan, dan memenuhi kebutuhan dokumentasi operasional. Data yang tidak lagi diperlukan dapat dihapus atau dianonimkan sesuai kebutuhan pengelolaan sistem.',
    ),
    _PrivacySection(
      number: '12',
      icon: Icons.lock_outline,
      title: 'Keamanan Data',
      content:
          'Akses data dibatasi berdasarkan kebutuhan pengguna dan admin. Sistem menggunakan autentikasi serta pengaturan akses pada basis data dan penyimpanan berkas. Meskipun langkah pengamanan diterapkan, tidak ada penyimpanan atau pengiriman data melalui internet yang dapat dijamin sepenuhnya bebas risiko.',
    ),
    _PrivacySection(
      number: '13',
      icon: Icons.tune_outlined,
      title: 'Pilihan dan Kendali Pengguna',
      content:
          'Pengguna dapat memperbarui nama, nomor telepon, foto profil, alamat tersimpan, serta metode pembayaran melalui aplikasi. Izin lokasi dan notifikasi dapat diatur melalui pengaturan perangkat, tetapi penolakan izin tertentu dapat menyebabkan sebagian fitur tidak berfungsi.',
    ),
    _PrivacySection(
      number: '14',
      icon: Icons.manage_accounts_outlined,
      title: 'Permintaan Perbaikan atau Penghapusan',
      content:
          'Pengguna dapat menghubungi admin untuk meminta pemeriksaan, perbaikan, atau penghapusan data akun. Sebagian informasi transaksi mungkin tetap disimpan apabila masih diperlukan untuk dokumentasi, keamanan, penyelesaian masalah, atau kewajiban operasional.',
    ),
    _PrivacySection(
      number: '15',
      icon: Icons.update_outlined,
      title: 'Perubahan Kebijakan',
      content:
          'Kebijakan Privasi dapat diperbarui apabila terdapat perubahan fitur, teknologi, kebutuhan keamanan, atau proses operasional. Tanggal pembaruan terbaru dicantumkan pada bagian atas halaman ini.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: _primaryRed,
          ),
        ),
        title: Text(
          'Kebijakan Privasi',
          style: GoogleFonts.poppins(
            color: const Color(0xFF202020),
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildIntroduction(),
          const SizedBox(height: 18),
          _buildDataOverview(),
          const SizedBox(height: 20),
          ..._sections.map(_buildSection),
          const SizedBox(height: 12),
          _buildContactCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC60D2A),
            Color(0xFFEC3349),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privasi Anda Penting',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pelajari data yang digunakan dan cara kami mengelolanya.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Diperbarui 28 Juli 2026',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1E8E9),
        ),
      ),
      child: Text(
        'Kebijakan ini menjelaskan jenis data yang diproses oleh aplikasi Lapar Manten Delivery, tujuan penggunaannya, pihak yang memperoleh informasi untuk menjalankan layanan, serta pilihan yang tersedia bagi pengguna.',
        textAlign: TextAlign.justify,
        style: GoogleFonts.poppins(
          color: const Color(0xFF665B5B),
          fontSize: 13,
          height: 1.65,
        ),
      ),
    );
  }

  Widget _buildDataOverview() {
    const List<_DataSummary> summaries = [
      _DataSummary(
        icon: Icons.person_outline,
        label: 'Akun',
      ),
      _DataSummary(
        icon: Icons.location_on_outlined,
        label: 'Lokasi',
      ),
      _DataSummary(
        icon: Icons.receipt_long_outlined,
        label: 'Pesanan',
      ),
      _DataSummary(
        icon: Icons.notifications_none,
        label: 'Notifikasi',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data yang mendukung layanan',
          style: GoogleFonts.poppins(
            color: const Color(0xFF292929),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: summaries
              .map(
                (summary) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: summary == summaries.last
                          ? 0
                          : 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius:
                          BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFF4D7DA),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          summary.icon,
                          color: _primaryRed,
                          size: 25,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summary.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color:
                                const Color(0xFF654E4E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSection(
    _PrivacySection section,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1E8E9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  section.icon,
                  color: _primaryRed,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF292929),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                section.number,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE6B9BE),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFF3EAEB),
          ),
          const SizedBox(height: 13),
          Text(
            section.content,
            textAlign: TextAlign.justify,
            style: GoogleFonts.poppins(
              color: const Color(0xFF665B5B),
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2525),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 31,
          ),
          const SizedBox(height: 10),
          Text(
            'Pertanyaan mengenai privasi?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _adminEmail,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(
                    text: _adminEmail,
                  ),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Email admin berhasil disalin.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.white54,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.copy,
                size: 18,
              ),
              label: Text(
                'Salin Email Admin',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection {
  final String number;
  final IconData icon;
  final String title;
  final String content;

  const _PrivacySection({
    required this.number,
    required this.icon,
    required this.title,
    required this.content,
  });
}

class _DataSummary {
  final IconData icon;
  final String label;

  const _DataSummary({
    required this.icon,
    required this.label,
  });
}
