import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapar_manten_delivery/screens/payment_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(List<Map<String, dynamic>>) onBackToHome;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onBackToHome,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final int shippingFee = 11000;
  final int serviceFee = 2000;

  // List untuk menyimpan status centang setiap item
  List<bool> selectedItems = [];

  @override
  void initState() {
    super.initState();
    // Di awal, otomatis centang semua item yang ada di keranjang
    selectedItems = List<bool>.filled(widget.cartItems.length, true);
  }

  // Mengatur ulang panjang list centang jika ada item yang dihapus
  void _updateSelectedItemsLength() {
    if (selectedItems.length != widget.cartItems.length) {
      selectedItems = List<bool>.filled(widget.cartItems.length, true);
    }
  }

  // Fungsi hitung subtotal - HANYA yang dicentang
  int calculateSubtotal() {
    int subtotal = 0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      if (i < selectedItems.length && selectedItems[i]) {
        subtotal += (widget.cartItems[i]['totalPrice'] as int);
      }
    }
    return subtotal;
  }

  // Mengecek apakah ada minimal satu item yang dicentang
  bool hasSelectedItems() {
    return selectedItems.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    _updateSelectedItemsLength();
   int subtotalMenu = calculateSubtotal();

bool anyChecked = hasSelectedItems();

int totalPayment = subtotalMenu == 0 
    ? 0 
    : subtotalMenu + shippingFee + serviceFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black),
  onPressed: () {
    widget.onBackToHome(widget.cartItems);
  },
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
                          onTap: () {
  widget.onBackToHome(widget.cartItems);
},
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

                  // DAFTAR MAKANAN DENGAN CHECKBOX
                  _buildCartListSection(),

                  // RINGKASAN PEMBAYARAN
                  _buildPaymentSummarySection(
  subtotalMenu,
  totalPayment,
  anyChecked,
),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildCartListSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cartItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        int singlePrice = (item['totalPrice'] as int) ~/ (item['quantity'] as int);

        // Memastikan index selectedItems aman beriringan dengan manipulasi data
        if (index >= selectedItems.length) {
          selectedItems.add(true);
        }

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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan checkbox di tengah vertikal card
            children: [
              // --- KOTAK CENTANG (CHECKBOX) ---
              Checkbox(
                activeColor: Colors.red,
                value: selectedItems[index],
                onChanged: (bool? value) {
                  setState(() {
                    selectedItems[index] = value ?? false;
                  });
                },
              ),
              
              // Gambar Makanan
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item['imagePath'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

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
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.cartItems.removeAt(index);
                              selectedItems.removeAt(index);
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
                                      item['totalPrice'] = singlePrice * item['quantity'];
                                    } else {
                                      widget.cartItems.removeAt(index);
                                      selectedItems.removeAt(index);
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
                                    item['totalPrice'] = singlePrice * item['quantity'];
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

  Widget _buildPaymentSummarySection(int subtotal, int totalPayment, bool anyChecked) {
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
          _buildSummaryRow("Biaya Ongkir", anyChecked ? "Rp $shippingFee" : "Rp 0"),
          _buildSummaryRow("Biaya Layanan", anyChecked ? "Rp $serviceFee" : "Rp 0"),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            "Total Pembayaran",
            "Rp $totalPayment",
            isTotal: true,
          ),
          const SizedBox(height: 20),

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
                backgroundColor: anyChecked ? Colors.red : Colors.grey, // Berubah abu jika kosong
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: !anyChecked 
                ? null // Tombol mati total jika tidak ada makanan dicentang
                : () async {
                  // Filter hanya makanan yang diberi centang untuk dikirim ke halaman pembayaran
                  List<Map<String, dynamic>> checkedItems = [];
                  for (int i = 0; i < widget.cartItems.length; i++) {
                    if (selectedItems[i]) {
                      checkedItems.add(widget.cartItems[i]);
                    }
                  }

                  // 1. Generate detail pesanan terpilih otomatis
                  String generateDetailPesanan() {
                    List<String> rincian = [];
                    for (var item in checkedItems) {
                      String detail = "${item['name']} ${item['varian']} (${item['quantity']}x)";
                      if (item['extras'] != null && (item['extras'] as List).isNotEmpty) {
                        String extrasText = (item['extras'] as List).join(', ');
                        detail += " + Tambahan: $extrasText";
                      }
                      rincian.add(detail);
                    }
                    return rincian.join('\n');
                  }

                  // 2. Generate catatan terpilih otomatis
                  String generateCatatanPesanan() {
                    List<String> semuaCatatan = [];
                    for (var item in checkedItems) {
                      if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) {
                        semuaCatatan.add("${item['name']}: ${item['catatan']}");
                      }
                    }
                    return semuaCatatan.isEmpty ? "-" : semuaCatatan.join(', ');
                  }

                  // Kirim data ke PaymentPage
                  // Kirim data ke PaymentPage
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentPage(
      cartItems: checkedItems, // Hanya kirim yang dicentang!
      subtotal: subtotal,
      detailVarianYangDipilih: generateDetailPesanan(),
      catatan: generateCatatanPesanan(),
      metodePembayaranDipilih: "COD",
    ),
  ),
).then((isCheckoutSuccess) {
  // KODE INI AKAN BERJALAN SAAT USER KEMBALI DARI PAYMENT PAGE
  // Jika Anda ingin menghapusnya setelah benar-benar sukses bayar, gunakan Cara 2.
});

// TAMBAHKAN KODE INI TEPAT DI BAWAH NAVIGATOR.PUSH UNTUK MENGOSONGKAN YANG DICENTANG:
setState(() {
  // Hapus item yang sudah checkout
  for (int i = widget.cartItems.length - 1; i >= 0; i--) {
    if (selectedItems[i]) {
      widget.cartItems.removeAt(i);
    }
  }

  selectedItems = List<bool>.filled(widget.cartItems.length, true);
});


// SIMPAN DATA KERANJANG TERBARU
try {
  final prefs = await SharedPreferences.getInstance();

  String encodedData = jsonEncode(widget.cartItems);

  await prefs.setString(
    'saved_cart',
    encodedData,
  );

  print("Keranjang berhasil diperbarui");
} catch (e) {
  print("Gagal simpan keranjang: $e");
}
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