import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  static const Color _primaryRed =
      Color(0xFFC60D2A);

  static const List<_TermSection> _sections = [
    _TermSection(
      number: '01',
      icon: Icons.handshake_outlined,
      title: 'Persetujuan Pengguna',
      content:
          'Dengan membuat akun atau menggunakan layanan Lapar Manten Delivery, pengguna dianggap telah membaca, memahami, dan menyetujui ketentuan yang tercantum pada halaman ini. Apabila tidak menyetujui ketentuan tersebut, pengguna dapat menghentikan penggunaan aplikasi.',
    ),
    _TermSection(
      number: '02',
      icon: Icons.person_outline,
      title: 'Akun Pengguna',
      content:
          'Pengguna wajib memberikan data akun yang benar dan dapat dihubungi. Pengguna bertanggung jawab menjaga keamanan email, kata sandi, nomor telepon, dan akses ke perangkatnya. Aktivitas yang dilakukan melalui akun pengguna menjadi tanggung jawab pemilik akun.',
    ),
    _TermSection(
      number: '03',
      icon: Icons.grid_view_outlined,
      title: 'Layanan yang Tersedia',
      content:
          'Aplikasi menyediakan layanan pemesanan atau jasa titip makanan, ojek, dan pengiriman barang. Ketersediaan layanan, menu, driver, wilayah operasional, serta waktu pelayanan dapat berubah sesuai kondisi operasional Lapar Manten Delivery.',
    ),
    _TermSection(
      number: '04',
      icon: Icons.receipt_long_outlined,
      title: 'Data dan Konfirmasi Pesanan',
      content:
          'Pengguna wajib memeriksa nama menu, varian, tambahan, jumlah, penerima, nomor telepon, lokasi, detail alamat, metode pembayaran, dan total biaya sebelum melakukan konfirmasi. Pesanan yang telah dikonfirmasi akan diteruskan kepada admin untuk diperiksa dan diproses.',
    ),
    _TermSection(
      number: '05',
      icon: Icons.location_on_outlined,
      title: 'Lokasi dan Alamat Pengantaran',
      content:
          'Pengguna wajib memberikan titik lokasi dan detail alamat yang sesuai dengan tujuan sebenarnya. Detail seperti nama jalan, nomor bangunan, warna rumah, nama gang, atau patokan terdekat diperlukan agar driver dapat menemukan lokasi dengan lebih mudah.',
    ),
    _TermSection(
      number: '06',
      icon: Icons.gps_off_outlined,
      title: 'Larangan Manipulasi Lokasi',
      content:
          'Pengguna dilarang menggunakan Fake GPS, Mock Location, atau cara lain untuk memanipulasi lokasi. Aplikasi dapat menghentikan proses checkout apabila lokasi terindikasi tidak valid. Pemeriksaan tersebut digunakan untuk meningkatkan keamanan dan keakuratan pengantaran.',
    ),
    _TermSection(
      number: '07',
      icon: Icons.payments_outlined,
      title: 'Harga dan Ongkos Pengantaran',
      content:
          'Harga menu, tambahan, biaya layanan, dan ongkos pengantaran ditampilkan sebelum pesanan dikonfirmasi. Pengantaran di dalam wilayah Kota Sumedang menggunakan tarif Rp11.000. Tujuan di luar wilayah tersebut dikenakan tambahan Rp2.000 per kilometer dari batas kota sesuai perhitungan sistem.',
    ),
    _TermSection(
      number: '08',
      icon: Icons.account_balance_wallet_outlined,
      title: 'Pembayaran',
      content:
          'Pembayaran dapat dilakukan menggunakan metode yang tersedia pada aplikasi, termasuk Cash on Delivery (COD) atau transfer. Pengguna yang memilih transfer wajib mengunggah bukti pembayaran yang benar dan dapat dibaca. Admin berhak memeriksa pembayaran sebelum pesanan diproses.',
    ),
    _TermSection(
      number: '09',
      icon: Icons.cancel_outlined,
      title: 'Pembatalan Pesanan',
      content:
          'Permintaan pembatalan harus disampaikan secepatnya kepada admin. Pembatalan mungkin tidak dapat dilakukan apabila makanan sudah dibeli, driver sudah melakukan perjalanan, barang sudah dijemput, atau layanan telah diproses. Penyelesaian biaya akan disesuaikan dengan kondisi pesanan.',
    ),
    _TermSection(
      number: '10',
      icon: Icons.inventory_2_outlined,
      title: 'Ketentuan Kirim Barang',
      content:
          'Pengguna wajib memberikan informasi jenis dan kondisi barang dengan benar. Barang terlarang, berbahaya, melanggar hukum, mudah meledak, senjata, narkotika, serta barang lain yang membahayakan tidak boleh dikirim melalui layanan Lapar Manten Delivery.',
    ),
    _TermSection(
      number: '11',
      icon: Icons.two_wheeler_outlined,
      title: 'Driver dan Proses Pengantaran',
      content:
          'Admin memilih driver berdasarkan ketersediaan operasional. Estimasi penjemputan dan pengantaran dapat berubah karena lalu lintas, cuaca, antrean restoran, kondisi kendaraan, kesalahan alamat, atau keadaan lain di lapangan.',
    ),
    _TermSection(
      number: '12',
      icon: Icons.block_outlined,
      title: 'Penggunaan yang Dilarang',
      content:
          'Pengguna dilarang membuat pesanan palsu, memberikan identitas atau bukti pembayaran palsu, menyalahgunakan akun, mengganggu driver atau admin, mencoba merusak sistem, serta menggunakan aplikasi untuk aktivitas yang melanggar hukum.',
    ),
    _TermSection(
      number: '13',
      icon: Icons.wifi_off_outlined,
      title: 'Ketersediaan Sistem',
      content:
          'Aplikasi membutuhkan koneksi internet, GPS, dan layanan pihak ketiga agar dapat bekerja. Gangguan jaringan, perangkat, server, peta, layanan cloud, atau pemeliharaan dapat memengaruhi akses dan proses transaksi.',
    ),
    _TermSection(
      number: '14',
      icon: Icons.update_outlined,
      title: 'Perubahan Ketentuan',
      content:
          'Lapar Manten Delivery dapat memperbarui ketentuan untuk menyesuaikan perubahan fitur, aturan operasional, keamanan, atau kebutuhan layanan. Tanggal pembaruan akan dicantumkan pada bagian atas halaman ini.',
    ),
    _TermSection(
      number: '15',
      icon: Icons.support_agent_outlined,
      title: 'Kontak dan Penyelesaian Kendala',
      content:
          'Apabila terjadi kendala, pengguna dapat membuka menu Pusat Bantuan dan menghubungi admin. Sertakan nomor pesanan serta penjelasan masalah agar pemeriksaan dapat dilakukan dengan lebih cepat.',
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
          'Syarat & Ketentuan',
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
          _buildNotice(),
          const SizedBox(height: 20),
          ..._sections.map(_buildSection),
          const SizedBox(height: 12),
          _buildClosingCard(),
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
              Icons.description_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketentuan Penggunaan',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Harap membaca ketentuan berikut sebelum menggunakan layanan.',
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

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF4C8CC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: _primaryRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ketentuan ini berlaku untuk penggunaan aplikasi pelanggan dan seluruh layanan yang tersedia di dalamnya.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF654E4E),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(_TermSection section) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildClosingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2525),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 31,
          ),
          const SizedBox(height: 10),
          Text(
            'Terima kasih telah menggunakan\nLapar Manten Delivery',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Gunakan layanan secara bertanggung jawab dan pastikan setiap data pesanan sudah benar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermSection {
  final String number;
  final IconData icon;
  final String title;
  final String content;

  const _TermSection({
    required this.number,
    required this.icon,
    required this.title,
    required this.content,
  });
}
