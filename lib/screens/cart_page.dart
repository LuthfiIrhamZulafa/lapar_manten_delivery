import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapar_manten_delivery/screens/payment_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Biaya tambahan statis sesuai gambar referensi kamu
  final int shippingFee = 12000;
  final int serviceFee = 2000;

  // Fungsi hitung subtotal makanan saja
  int calculateSubtotal() {
    int subtotal = 0;
    for (var item in widget.cartItems) {
      subtotal += (item['totalPrice'] as int);
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = calculateSubtotal();
    int totalPayment = subtotal == 0 ? 0 : subtotal + shippingFee + serviceFee;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Background abu-abu soft bersih sesuai gambar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Keranjang",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // HEADER PESANAN ANDA
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pesanan Anda",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(
                            context,
                          ), // Balik ke beranda buat tambah porsi
                          child: Text(
                            "Tambah Pesanan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DAFTAR MAKANAN (CARD)
                  _buildCartListSection(),

                  // RINGKASAN PEMBAYARAN
                  _buildPaymentSummarySection(subtotal, totalPayment),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // 1. WIDGET DAFTAR MAKANAN (CARD)
  Widget _buildCartListSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cartItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        // Hitung harga satuan dasar (total harga dibagi qty awal)
        int singlePrice =
            (item['totalPrice'] as int) ~/ (item['quantity'] as int);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Makanan Kotak Rapi
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item['imagePath'],
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      width: 85,
                      height: 85,
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Info Detail Teks Makanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Tombol Tong Sampah untuk Hapus Menu
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.cartItems.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Varian: ${item['varian']}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if ((item['extras'] as List).isNotEmpty)
                      Text(
                        "Tambahan: ${(item['extras'] as List).join(', ')}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),

                    // Baris Harga & Tombol Plus-Minus Kuantitas (- 1 +)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rp ${item['totalPrice']}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),

                        // Tombol Pengatur Jumlah Kuantitas (- 1 +)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                      item['totalPrice'] =
                                          singlePrice * item['quantity'];
                                    } else {
                                      widget.cartItems.removeAt(index);
                                    }
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Text(
                                "${item['quantity']}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    item['quantity']++;
                                    item['totalPrice'] =
                                        singlePrice * item['quantity'];
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. WIDGET RINGKASAN PEMBAYARAN & TOMBOL MERAH
  Widget _buildPaymentSummarySection(int subtotal, int totalPayment) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ringkasan Pembayaran",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("Subtotal", "Rp $subtotal"),
          _buildSummaryRow("Biaya Ongkir", "Rp $shippingFee"),
          _buildSummaryRow("Biaya Layanan", "Rp $serviceFee"),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            "Total Pembayaran",
            "Rp $totalPayment",
            isTotal: true,
          ),
          const SizedBox(height: 20),

          // Kartu Promo "Makin hemat pakai promo"
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Makin hemat pakai promo",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Merah Panjang "Lanjut ke Pembayaran"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              // --- PASANG INI PADA TOMBOL ELEVATEDBUTTON DI CART_PAGE.DART ---
              onPressed: () {
                // Hitung subtotal dari semua item yang ada di keranjang
                int hitungSubtotal = 0;
                for (var item in widget.cartItems) {
                  hitungSubtotal += (item['totalPrice'] as int);
                }

                // Berpindah ke halaman pembayaran bawa data keranjang
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      cartItems: widget.cartItems,
                      subtotal: hitungSubtotal,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lanjut ke Pembayaran",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 15 : 14,
              color: isTotal ? Colors.black87 : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 3. TAMPILAN JIKA KERANJANG KOSONG
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Keranjangmu masih kosong",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
