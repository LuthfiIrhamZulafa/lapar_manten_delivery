import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_food_page.dart';

class MakananPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Future<void> Function() onCartChanged;
  final String initialSearchQuery;

  const MakananPage({
    super.key,
    required this.cartItems,
    required this.onCartChanged,
    this.initialSearchQuery = '',
  });

  @override
  State<MakananPage> createState() => _MakananPageState();
}

class _MakananPageState extends State<MakananPage> {
  static const Color _primaryRed = Color(0xFFC60D2A);

  String _selectedCategory = 'Rekomendasi';

late final TextEditingController _searchController;
late String _searchQuery;

@override
void initState() {
  super.initState();

  _searchQuery = widget.initialSearchQuery.trim();

  _searchController = TextEditingController(
    text: _searchQuery,
  );
}

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

  final List<String> _categories = const [
    'Rekomendasi',
    'Mie',
    'Roti & Kopi',
    'Martabak',
    'Sate',
    'Bakso',
  ];

  final List<_FoodData> _foods = [
    _FoodData(
      name: 'Mie Gacoan',
      category: 'Mie',
      description:
          'Mie pedas pilihan masyarakat Sumedang dengan rasa yang nagih.',
      imagePath: 'assets/images/gacoan.png',
      rating: '4.8',
      reviews: '1.2k+',
      duration: '15–20 mnt',
      startPrice: 11000,
      isBestSeller: true,
      variants: [
        {'name': 'Mie Gacoan Level 0', 'price': 11000},
        {'name': 'Mie Gacoan Level 1-4', 'price': 12000},
        {'name': 'Mie Gacoan Level 6-8', 'price': 14000},
        {'name': 'Mie Hompimpa Level 0', 'price': 11000},
        {'name': 'Mie Hompimpa Level 1-4', 'price': 12000},
        {'name': 'Mie Hompimpa Level 6-8', 'price': 14000},
        {'name': 'Mie Suit (Tidak Pedas)', 'price': 11000},
      ],
      extras: [
        {'name': 'Siomay (isi 3)', 'price': 10000},
        {'name': 'Udang Keju (isi 3)', 'price': 11000},
        {'name': 'Udang Rambutan (isi 3)', 'price': 11000},
        {'name': 'Pangsit Goreng (isi 3)', 'price': 10000},
        {'name': 'Es Gobak Sodor', 'price': 9500},
        {'name': 'Es Teklek', 'price': 9500},
        {'name': 'Es Sluku Bathok', 'price': 7500},
        {'name': 'Es Nyore', 'price': 8000},
      ],
    ),
    _FoodData(
      name: "Roti'O - Asia Plaza Sumedang",
      category: 'Roti & Kopi',
      description:
          'Roti bun beraroma kopi, renyah di luar dan lembut di dalam.',
      imagePath: "assets/images/roti'o.png",
      rating: '4.9',
      reviews: '800+',
      duration: '20–25 mnt',
      startPrice: 13000,
      variants: [
        {'name': "Roti'O Original Coffee Bun", 'price': 13000},
        {'name': "Roti'O Chocolate Pastry", 'price': 15000},
        {'name': "Roti'O Cheese Pastry", 'price': 15000},
        {'name': "Roti'O Almond Pastry", 'price': 17000},
      ],
      extras: [
        {'name': 'Ice Blend Coffee Oreo', 'price': 20000},
        {'name': 'Ice Blend Caramel', 'price': 20000},
        {'name': 'Hot/Ice Americano', 'price': 15000},
        {'name': 'Hot/Ice Cafe Latte', 'price': 18000},
        {'name': 'Choco Latte', 'price': 18000},
      ],
    ),
    _FoodData(
      name: 'Martabak Legit Group',
      category: 'Martabak',
      description: 'Martabak legendaris dengan adonan rahasia yang lembut.',
      // Ganti dengan assets/images/martabak_legit.png setelah gambarnya tersedia.
      imagePath: 'assets/images/martabak_legit.png',
      rating: '4.7',
      reviews: '650+',
      duration: '20–30 mnt',
      startPrice: 55000,
      variants: [
        {'name': 'Martabak Manis Cokelat Keju', 'price': 55000},
        {'name': 'Martabak Manis Keju Susu', 'price': 50000},
        {'name': 'Martabak Telur Spesial', 'price': 60000},
      ],
      extras: [
        {'name': 'Tambahan Keju', 'price': 10000},
        {'name': 'Tambahan Cokelat', 'price': 8000},
      ],
    ),
    _FoodData(
      name: 'Sate Ketib',
      category: 'Sate',
      description: 'Perpaduan daging sapi dan jantung dengan bumbu khas.',
      // Ganti dengan assets/images/sate_ketib.png setelah gambarnya tersedia.
      imagePath: 'assets/images/sate_ketib.png',
      rating: '4.8',
      reviews: '500+',
      duration: '20–25 mnt',
      startPrice: 38000,
      variants: [
        {'name': 'Sate Sapi 10 Tusuk', 'price': 38000},
        {'name': 'Sate Campur 10 Tusuk', 'price': 38000},
      ],
      extras: [
        {'name': 'Lontong', 'price': 5000},
        {'name': 'Nasi', 'price': 6000},
      ],
    ),
    _FoodData(
      name: 'Bakso Sekar Kutamaya',
      category: 'Bakso',
      description: 'Bola daging sapi premium yang kenyal, gurih, dan padat.',
      // Ganti dengan assets/images/bakso_sekar.png setelah gambarnya tersedia.
      imagePath: 'assets/images/bakso_sekar.png',
      rating: '4.7',
      reviews: '420+',
      duration: '15–25 mnt',
      startPrice: 18000,
      variants: [
        {'name': 'Bakso Biasa', 'price': 18000},
        {'name': 'Bakso Urat', 'price': 22000},
      ],
      extras: [
        {'name': 'Mie Tambahan', 'price': 4000},
        {'name': 'Tahu', 'price': 3000},
      ],
    ),
  ];

  List<_FoodData> get _filteredFoods {
  Iterable<_FoodData> hasil = _foods;

  if (_selectedCategory != 'Rekomendasi') {
    hasil = hasil.where(
      (food) => food.category == _selectedCategory,
    );
  }

  final String kata =
      _searchQuery.trim().toLowerCase();

  if (kata.isNotEmpty) {
    hasil = hasil.where((food) {
      final String namaVarian = food.variants
          .map((item) => item['name']?.toString() ?? '')
          .join(' ');

      final String namaTambahan = food.extras
          .map((item) => item['name']?.toString() ?? '')
          .join(' ');

      final String dataPencarian = [
        food.name,
        food.category,
        food.description,
        namaVarian,
        namaTambahan,
      ].join(' ').toLowerCase();

      return dataPencarian.contains(kata);
    });
  }

  return hasil.toList();
}

  int get _cartQuantity {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + ((item['quantity'] as num?)?.toInt() ?? 0),
    );
  }

  int get _cartTotal {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + ((item['totalPrice'] as num?)?.toInt() ?? 0),
    );
  }

  Future<void> _openFoodDetail(_FoodData food) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailFoodPage(
          name: food.name,
          imagePath: food.imagePath,
          description: food.description,
          varianList: food.variants,
          tambahanList: food.extras,
          cartItems: widget.cartItems,
        ),
      ),
    );

    await widget.onCartChanged();

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LAPAR MANTEN',
          style: GoogleFonts.poppins(
            color: _primaryRed,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
     body: Builder(
  builder: (context) {
    final List<_FoodData> hasilPencarian =
        _filteredFoods;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHero(),

        _buildFoodSearchBar(),

        _buildCategoryTabs(),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            8,
          ),
          child: Text(
            _searchQuery.trim().isEmpty
                ? 'Paling Populer'
                : 'Hasil Pencarian',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF292929),
            ),
          ),
        ),

        ...hasilPencarian.map(_buildFoodCard),

        if (hasilPencarian.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  'Makanan yang dicari tidak ditemukan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  },
),
      bottomNavigationBar:
          widget.cartItems.isEmpty ? null : _buildCartSummary(),
    );
  }

  Widget _buildHero() {
    final _FoodData heroFood = _foods.first;

    return InkWell(
      onTap: () => _openFoodDetail(heroFood),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              heroFood.imagePath,
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (heroFood.isBestSeller)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF01E2D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'BEST SELLER',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    heroFood.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFA6AC), size: 22),
                      const SizedBox(width: 5),
                      Text(
                        '${heroFood.rating} (${heroFood.reviews} ratings)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFFFA6AC),
                        size: 21,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        heroFood.duration,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
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
    );
  }

  Widget _buildFoodSearchBar() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari makanan, minuman, atau varian...',
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
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
        fillColor: const Color(0xFFF4F4F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

  Widget _buildCategoryTabs() {
    return Container(
      height: 88,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final String category = _categories[index];
          final bool selected = category == _selectedCategory;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: selected ? _primaryRed : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? _primaryRed
                      : const Color(0xFFF1B8BC),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _primaryRed.withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : const Color(0xFF654E4E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(_FoodData food) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openFoodDetail(food),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    food.imagePath,
                    width: 105,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 105,
                        height: 105,
                        color: const Color(0xFFFFE7E9),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.restaurant,
                          color: _primaryRed,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 105,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF242424),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Text(
                            food.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.5,
                              color: const Color(0xFF766666),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatRupiah(food.startPrice),
                                style: GoogleFonts.poppins(
                                  color: _primaryRed,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () => _openFoodDetail(food),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  elevation: 3,
                                  shadowColor: _primaryRed.withOpacity(0.30),
                                  backgroundColor: const Color(0xFFF21D2B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 27),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final Map<String, dynamic> lastItem = widget.cartItems.last;

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Material(
          color: _primaryRed,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF51E31),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_cartQuantity',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_cartQuantity item dalam keranjang',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          lastItem['name']?.toString() ?? 'Pesanan makanan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFC8CC),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatRupiah(_cartTotal),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.shopping_basket_outlined,
                    color: Colors.white,
                    size: 27,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRupiah(int value) {
    final String digits = value.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        result.write('.');
      }
      result.write(digits[index]);
    }

    return 'Rp ${result.toString()}';
  }
}

class _FoodData {
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final String rating;
  final String reviews;
  final String duration;
  final int startPrice;
  final bool isBestSeller;
  final List<Map<String, dynamic>> variants;
  final List<Map<String, dynamic>> extras;

  const _FoodData({
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.duration,
    required this.startPrice,
    required this.variants,
    required this.extras,
    this.isBestSeller = false,
  });
}
