import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int subtotal;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // 0 untuk Transfer Bank, 1 untuk COD
  int _selectedMethodIndex = 0;
  final int _biayaLayanan = 50000;

  @override
  Widget build(BuildContext context) {
    int totalBayar = widget.subtotal + _biayaLayanan;

    // Mengambil item pertama sebagai contoh ringkasan pesanan
    // (Bisa disesuaikan jika ingin melooping semua isi keranjang)
    var firstItem = widget.cartItems.isNotEmpty ? widget.cartItems[0] : {};

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "LAPAR MANTEN",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Menunggu Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD1D4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD31124),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Menunggu Pembayaran",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            children: const [
                              TextSpan(text: "Selesaikan pembayaran dalam "),
                              TextSpan(
                                text: "23:59:12",
                                style: TextStyle(
                                  color: Color(0xFFD31124),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Ringkasan Pesanan",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // 2. Card Ringkasan Pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: firstItem['imagePath'] != null
                            ? Image.asset(
                                firstItem['imagePath'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem['name'] ?? "Paket Makanan",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${firstItem['quantity'] ?? 1} Porsi • ${firstItem['varian'] ?? 'Default'}",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${widget.subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD31124),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  _buildPriceRow("Subtotal", widget.subtotal),
                  const SizedBox(height: 8),
                  _buildPriceRow("Biaya Layanan", _biayaLayanan),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Bayar",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${totalBayar.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD31124),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Instruksi Pembayaran",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Card Instruksi Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Tab Pilihan Metode
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Transfer Bank", 0),
                        _buildTabButton("Bayar di Tempat\n(COD)", 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Isi Instruksi berdasarkan Tab yang dipilih
                  _selectedMethodIndex == 0
                      ? _buildTransferBankView(totalBayar)
                      : _buildCodView(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Tombol Konfirmasi Pembayaran
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD31124),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Nanti di sini kita hubungkan ke fitur Upload Bukti Bayar skripsimu
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Melanjutkan ke konfirmasi pembayaran..."),
                    ),
                  );
                },
                child: Text(
                  "Konfirmasi Pembayaran",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        ),
        Text(
          "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedMethodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethodIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferBankView(int total) {
    const String nomorRekening = "883210923341";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005E9F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "BCA",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bank Central Asia (BCA)",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Admin Lapar Manten",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                // Perintah sakti untuk menyalin teks ke clipboard HP
                await Clipboard.setData(ClipboardData(text: nomorRekening));

                // Memunculkan notifikasi hitam kecil di bawah layar kalau sukses disalin
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Nomor rekening berhasil disalin!",
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors
                          .black87, // Menggunakan warna hitam agak abu elegan khas SnackBar
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Text(
                "SALIN",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD31124),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "8832 1092 3341",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStepInstruction(
          "1",
          "Transfer total biaya sesuai nominal di atas.",
        ),
        _buildStepInstruction(
          "2",
          "Pastikan nama pengirim sesuai dengan akun Anda.",
        ),
        _buildStepInstruction(
          "3",
          "Simpan bukti transfer dan unggah di bagian bawah.",
        ),
      ],
    );
  }

  Widget _buildCodView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Text(
        "Silakan siapkan uang tunai pas saat kurir Lapar Manten sampai di lokasi Anda.",
        style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStepInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: const Color(0xFFFFF0F1),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: const Color(0xFFD31124),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
