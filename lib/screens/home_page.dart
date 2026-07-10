import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_food_page.dart';
import 'package:lapar_manten_delivery/screens/cart_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mengambil data user yang sedang login dari Firebase
  final user = Supabase.instance.client.auth.currentUser;
  List<Map<String, dynamic>> globalCart = [];
  int _selectedIndex = 0;

  // Fungsi untuk MENYIMPAN keranjang ke memori HP
  Future<void> saveCartToStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Mengubah List Map menjadi teks biasa (String)
    String encodedData = jsonEncode(globalCart);
    await prefs.setString('saved_cart', encodedData);
  }

  // Fungsi untuk MENGAMBIL kembali data keranjang saat aplikasi dibuka
  Future<void> loadCartFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCart = prefs.getString('saved_cart');

    if (savedCart != null) {
      setState(() {
        // Mengubah teks kembali menjadi bentuk List asli
        globalCart = List<Map<String, dynamic>>.from(jsonDecode(savedCart));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCartFromStorage();
  }

  // Daftar halaman
  List<Widget> _getPages() {
  return [
    _buildIsiBerandaUtama(),

    CartPage(
  key: ValueKey(globalCart.length),
  cartItems: globalCart,

  onCartUpdated: (updatedCart) async {
    setState(() {
      globalCart = List<Map<String, dynamic>>.from(updatedCart);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_cart',
      jsonEncode(globalCart),
    );
  },

  onBackToHome: () {
    setState(() {
      _selectedIndex = 0;
    });
  },
),

  OrdersPage(
  onGoHome: () {
    setState(() {
      _selectedIndex = 0;
    });
  },
),

    const ProfilePage(),
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPages()[_selectedIndex],

      // Pindahkan BottomNavigationBar ke sini (sejajar dengan body)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,

        currentIndex: _selectedIndex,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: "Keranjang",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: "Orders",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo Aplikasi kecil di kiri
              Image.asset('assets/images/logo_lapar_manten.png', height: 35),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ANTAR KE",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Rumah - Sumedang", // Bisa diganti dinamis nanti
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Icon Notifikasi dengan titik merah
              Stack(
                children: [
                  const Icon(Icons.notifications_none_outlined, size: 28),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Foto Profil Google User
              CircleAvatar(
                radius: 18,
                // Menggunakan foto lokal dari folder assets
                backgroundImage: const AssetImage(
                  "assets/images/logo_profil.png",
                ),
                // Jika gambar gagal dimuat, akan menampilkan background warna
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Nasi Padang atau Minuman...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _categoryItem(
            "Makanan",
            "assets/images/logo_garpuh.png",
            const Color(0xFBA0013),
          ),
          _categoryItem(
            "Ojek",
            "assets/images/logo_motor.png",
            const Color(0xFBA0013),
          ),
          _categoryItem(
            "Kirim Barang",
            "assets/images/logo_kardus.png",
            const Color(0xFBA0013),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(String label, String imagePath, Color bgColor) {
    return Column(
      children: [
        Container(
          height: 65,
          width: 65,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return SizedBox(
      height: 160, // Sesuaikan tinggi
      child: ListView(
        scrollDirection: Axis.horizontal, // Membuatnya bisa digeser ke samping
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // BANNER 1 (BURGER)
          _itemBanner(
            "assets/images/gambar_promo_burger.png",
            "PROMO SPESIAL",
            "Diskon s/d 50%",
          ),

          const SizedBox(width: 12), // Jarak antar banner
          // BANNER 2 (SALAD - Gambar yang sepotong tadi)
          _itemBanner(
            "assets/images/gambar_promo_salad.png",
            "HEMAT ONGKIR",
            "Gratis Ongkir\nTanpa Syarat",
          ),
        ],
      ),
    );
  }

  // Fungsi pembantu agar kodingan tidak panjang berulang
  Widget _itemBanner(String imagePath, String tag, String title) {
    return Container(
      width: 300, // Lebar banner agar gambar selanjutnya kelihatan "ngintip"
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tag,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Lihat Semua",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(
    String name,
    String category,
    String distance,
    String rating,
    String reviews,
    int price,
    int? discountPrice,
    String imagePath,
    bool isPromo,
  ) {
    return GestureDetector(
      // <--- 1. Tambahkan GestureDetector
      onTap: () {
        // DATA VARIAN & TAMBAHAN
        List<Map<String, dynamic>> varianKirim = [];
        List<Map<String, dynamic>> tambahanKirim = [];
        String deskripsiKirim = "";

        // MENU GACOAN
        if (name.toLowerCase().contains("gacoan")) {
          deskripsiKirim =
              "Mie pedas pilihan masyarakat Sumedang dengan sensasi rasa yang nagih.";

          varianKirim = [
            {"name": "Mie Gacoan Level 0", "price": 11000},
            {"name": "Mie Gacoan Level 1-4", "price": 12000},
            {"name": "Mie Gacoan Level 6-8", "price": 14000},
            {"name": "Mie Hompimpa Level 0", "price": 11000},
            {"name": "Mie Hompimpa Level 1-4", "price": 12000},
            {"name": "Mie Hompimpa Level 6-8", "price": 14000},
            {"name": "Mie Suit (Tidak Pedas)", "price": 11000},
          ];
          tambahanKirim = [
            {"name": "Siomay (isi 3)", "price": 10000},
            {"name": "Udang Keju (isi 3)", "price": 11000},
            {"name": "Udang Rambutan (isi 3)", "price": 11000},
            {"name": "Pangsit Goreng (isi 3)", "price": 10000},
            {"name": "Es Gobak Sodor", "price": 9500},
            {"name": "Es Teklek", "price": 9500},
            {"name": "Es Sluku Bathok", "price": 7500},
            {"name": "Es Nyore", "price": 8000},
          ];
        }
        // MENU ROTI'O
        else if (name.toLowerCase().contains("roti")) {
          deskripsiKirim =
              "Roti bun khas dengan aroma kopi yang harum, renyah di luar dan lembut di dalam.";

          varianKirim = [
            {"name": "Roti'O Original Coffee Bun", "price": 13000},
            {"name": "Roti'O Chocolate Pastry", "price": 15000},
            {"name": "Roti'O Cheese Pastry", "price": 15000},
            {"name": "Roti'O Almond Pastry", "price": 17000},
          ];
          tambahanKirim = [
            {"name": "Ice Blend Coffee Oreo", "price": 20000},
            {"name": "Ice Blend Caramel", "price": 20000},
            {"name": "Hot/Ice Americano", "price": 15000},
            {"name": "Hot/Ice Café Latte", "price": 18000},
            {"name": "Choco Latte", "price": 18000},
          ];
        }
        // DEFAULT MENU
        else {
          deskripsiKirim = "Nikmati menu lezat pilihan terbaik untuk kamu.";

          varianKirim = [
            {"name": "Menu Biasa", "price": 20000},
          ];

          tambahanKirim = [
            {"name": "Air Mineral", "price": 5000},
          ];
        }

        // PINDAH KE DETAIL PAGE
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailFoodPage(
              name: name,
              imagePath: imagePath,
              description: deskripsiKirim,
              varianList: varianKirim,
              tambahanList: tambahanKirim,
              cartItems: globalCart,
            ),
          ),
        ).then((value) {
          // Simpan keranjang setelah kembali dari halaman detail
          saveCartToStorage();

          // Refresh tampilan
          setState(() {});
        });
      },
      child: Padding(
        // <--- Child dari GestureDetector adalah Padding yang sudah kamu buat
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          // ... SISA KODE KAMU DI BAWAH SAMA SEMUA ...
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Gambar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Promo Badge
                  if (isPromo)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Promo",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Bagian Info
              // Bagian Info
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rating & Jarak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 18,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              "$rating ($reviews)",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          distance,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIsiBerandaUtama() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            _buildSearchBar(),

            _buildCategories(),

            _buildPromoBanner(),

            _buildSectionTitle("Rekomendasi Untukmu"),

            _buildFoodCard(
              "Mie Gacoan",
              "Noodles",
              "2.4 km",
              "4.8",
              "1.2k+",
              65000,
              42000,
              "assets/images/gacoan.png",
              true,
            ),

            _buildFoodCard(
              "Roti'o - Asia Plaza sumedang",
              "Coffee • Roti",
              "3.1 km",
              "4.9",
              "800+",
              32000,
              null,
              "assets/images/roti'o.png",
              false,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
