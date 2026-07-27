import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() =>
      _HelpCenterPageState();
}

class _HelpCenterPageState
    extends State<HelpCenterPage> {
  static const Color _primaryRed =
      Color(0xFFC60D2A);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = const [
    'Semua',
    'Pesanan',
    'Pembayaran',
    'Lokasi',
    'Akun',
  ];

  final List<_HelpArticle> _articles = const [
    _HelpArticle(
      category: 'Pesanan',
      question: 'Bagaimana cara memesan makanan?',
      answer:
          'Pilih layanan Makanan pada beranda, pilih menu yang diinginkan, tentukan varian, tambahan, dan jumlah, kemudian masukkan pesanan ke keranjang. Periksa kembali keranjang sebelum melanjutkan ke pembayaran.',
    ),
    _HelpArticle(
      category: 'Pesanan',
      question:
          'Mengapa tombol checkout tidak dapat ditekan?',
      answer:
          'Pastikan keranjang tidak kosong, nama dan nomor telepon penerima sudah diisi, detail alamat sudah lengkap, GPS serta izin lokasi sudah aktif, dan metode pembayaran sudah dipilih. Untuk pembayaran transfer, bukti pembayaran juga wajib diunggah.',
    ),
    _HelpArticle(
      category: 'Pesanan',
      question:
          'Bagaimana cara memesan untuk orang lain?',
      answer:
          'Pada halaman pembayaran, tekan tombol Kirim ke Orang Terdekat. Isi nama penerima, nomor telepon, alamat, patokan, dan tentukan titik tujuan pada peta. Periksa kembali data tersebut sebelum mengonfirmasi pesanan.',
    ),
    _HelpArticle(
      category: 'Pesanan',
      question:
          'Di mana saya dapat melihat status pesanan?',
      answer:
          'Buka menu Orders pada navigasi bagian bawah. Pesanan yang masih berjalan dan riwayat pesanan akan ditampilkan beserta status terbaru yang diberikan oleh admin.',
    ),
    _HelpArticle(
      category: 'Pesanan',
      question:
          'Bagaimana menggunakan layanan Ojek?',
      answer:
          'Pilih Ojek pada beranda, tentukan lokasi penjemputan dan tujuan, periksa jarak serta ongkos, pilih metode pembayaran, lalu tekan Pesan Sekarang. Status perjalanan dapat dilihat melalui halaman Orders.',
    ),
    _HelpArticle(
      category: 'Pesanan',
      question:
          'Bagaimana menggunakan layanan Kirim Barang?',
      answer:
          'Pilih Kirim Barang pada beranda. Isi data pengirim dan penerima, tentukan lokasi penjemputan dan tujuan, tambahkan detail atau patokan alamat, pilih jenis paket, lalu konfirmasi pesanan.',
    ),
    _HelpArticle(
      category: 'Pembayaran',
      question:
          'Metode pembayaran apa yang tersedia?',
      answer:
          'Lapar Manten Delivery menyediakan pembayaran Cash on Delivery (COD) dan transfer. Ketersediaan metode dapat disesuaikan dengan jenis layanan yang dipilih.',
    ),
    _HelpArticle(
      category: 'Pembayaran',
      question:
          'Mengapa bukti transfer harus diunggah?',
      answer:
          'Bukti transfer digunakan oleh admin untuk memeriksa pembayaran dan menjadi bagian dari catatan transaksi. Pastikan foto bukti terlihat jelas dan sesuai dengan nominal pesanan.',
    ),
    _HelpArticle(
      category: 'Pembayaran',
      question:
          'Bagaimana ongkos pengantaran dihitung?',
      answer:
          'Pengantaran di dalam wilayah Kota Sumedang dikenakan tarif Rp11.000. Untuk tujuan di luar wilayah tersebut, terdapat tambahan Rp2.000 per kilometer yang dihitung dari batas kota menuju lokasi tujuan.',
    ),
    _HelpArticle(
      category: 'Lokasi',
      question:
          'Mengapa lokasi saya tidak terdeteksi?',
      answer:
          'Pastikan GPS aktif, aplikasi telah memperoleh izin lokasi, koneksi internet tersedia, dan perangkat tidak berada di tempat yang menghalangi sinyal GPS. Setelah itu, buka kembali halaman lokasi.',
    ),
    _HelpArticle(
      category: 'Lokasi',
      question:
          'Mengapa checkout diblokir saat Fake GPS aktif?',
      answer:
          'Aplikasi melakukan pemeriksaan keamanan lokasi untuk membantu memastikan tujuan pengantaran valid. Nonaktifkan aplikasi Fake GPS atau Mock Location, gunakan lokasi perangkat yang sebenarnya, kemudian coba kembali.',
    ),
    _HelpArticle(
      category: 'Lokasi',
      question:
          'Mengapa detail atau patokan alamat diperlukan?',
      answer:
          'Titik pada peta terkadang belum menunjukkan posisi rumah secara rinci. Detail seperti warna rumah, nomor bangunan, nama gang, atau patokan terdekat membantu driver menemukan lokasi dengan lebih mudah.',
    ),
    _HelpArticle(
      category: 'Akun',
      question:
          'Bagaimana cara mengubah data profil?',
      answer:
          'Buka menu Profile, pilih Edit Profil, kemudian ubah nama, nomor telepon, atau foto profil. Tekan Simpan Perubahan agar data terbaru tersimpan.',
    ),
    _HelpArticle(
      category: 'Akun',
      question:
          'Bagaimana cara menyimpan alamat?',
      answer:
          'Buka menu Profile, pilih Alamat Tersimpan, lalu tambahkan alamat baru. Tentukan titik lokasi pada peta dan lengkapi data penerima serta patokan alamat.',
    ),
  ];

  List<_HelpArticle> get _filteredArticles {
    final String query =
        _searchQuery.trim().toLowerCase();

    return _articles.where((article) {
      final bool categoryMatches =
          _selectedCategory == 'Semua' ||
              article.category == _selectedCategory;

      final String searchableText =
          '${article.question} ${article.answer} '
                  '${article.category}'
              .toLowerCase();

      final bool queryMatches =
          query.isEmpty ||
              searchableText.contains(query);

      return categoryMatches && queryMatches;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_HelpArticle> displayedArticles =
        _filteredArticles;

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
          'Pusat Bantuan',
          style: GoogleFonts.poppins(
            color: const Color(0xFF202020),
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _buildSearchField(),
          _buildCategoryFilter(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  color: _primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Pertanyaan yang sering diajukan',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF242424),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (displayedArticles.isEmpty)
            _buildEmptyState()
          else
            ...displayedArticles.map(
              _buildQuestionCard,
            ),
          _buildContactCard(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        12,
      ),
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
              Icons.support_agent,
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
                  'Ada yang bisa kami bantu?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Temukan jawaban mengenai pesanan, pembayaran, lokasi, dan akun.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        10,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari bantuan...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _primaryRed,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFF0E5E6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: _primaryRed,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 49,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final String category =
              _categories[index];
          final bool selected =
              category == _selectedCategory;

          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
            label: Text(
              category,
              style: GoogleFonts.poppins(
                color: selected
                    ? Colors.white
                    : const Color(0xFF654E4E),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            selectedColor: _primaryRed,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? _primaryRed
                  : const Color(0xFFEACFD2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    _HelpArticle article,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        6,
        20,
        6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor:
              _primaryRed.withOpacity(0.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 3,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          leading: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8EA),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              _categoryIcon(article.category),
              color: _primaryRed,
              size: 21,
            ),
          ),
          title: Text(
            article.question,
            style: GoogleFonts.poppins(
              color: const Color(0xFF292929),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: _primaryRed,
          collapsedIconColor: Colors.grey,
          children: [
            const Divider(
              color: Color(0xFFF3EAEB),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                article.answer,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF665B5B),
                  fontSize: 13,
                  height: 1.65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 36,
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              color: _primaryRed,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Bantuan tidak ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata pencarian yang berbeda atau hubungi admin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        0,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF4C8CC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: _primaryRed,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masih membutuhkan bantuan?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF292929),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Hubungi admin Lapar Manten untuk pemeriksaan lebih lanjut.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF766666),
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showContactDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.mail_outline,
                size: 21,
              ),
              label: Text(
                'Lihat Kontak Admin',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContactDialog() async {
    const String adminEmail =
        'laparmanten09@gmail.com';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Kontak Admin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jelaskan nomor pesanan dan kendala yang dialami agar admin dapat membantu lebih cepat.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3F3),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: _primaryRed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        adminEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(
                    text: adminEmail,
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (!mounted) return;

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
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.copy,
                size: 18,
              ),
              label: Text(
                'Salin Email',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pembayaran':
        return Icons.account_balance_wallet_outlined;
      case 'Lokasi':
        return Icons.location_on_outlined;
      case 'Akun':
        return Icons.person_outline;
      case 'Pesanan':
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

class _HelpArticle {
  final String category;
  final String question;
  final String answer;

  const _HelpArticle({
    required this.category,
    required this.question,
    required this.answer,
  });
}
