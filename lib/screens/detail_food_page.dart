import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailFoodPage extends StatefulWidget {
  final String name;
  final String imagePath;
  final int price;

  const DetailFoodPage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  @override
  State<DetailFoodPage> createState() => _DetailFoodPageState();
}

class _DetailFoodPageState extends State<DetailFoodPage> {
  int quantity = 1;

  String selectedMie = ""; // Untuk menyimpan mie yang dipilih
  List<String> selectedExtras = []; // Untuk menyimpan daftar dimsum/minuman

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Gambar latar belakang (seperti kode sebelumnya)
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Tombol Back
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. Konten yang bisa di-scroll
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // NAMA DAN HARGA (Mirip desain Martabak Legit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Rp ${widget.price}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Mie pedas pilihan masyarakat Sumedang.",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),

                    // --- TARUH SEMUA LIST MENU DI SINI ---
                    _buildSectionHeader("Pilih Mie", "Wajib dipilih"),
                    _buildRequiredOption("Mie Suit (Original)", "Rp 10.000"),
                    _buildRequiredOption("Mie Hompimpa (Lv 1-4)", "Rp 10.000"),
                    _buildRequiredOption("Mie Hompimpa (Lv 6-8)", "Rp 11.000"),
                    _buildRequiredOption("Mie Gacoan (Lv 0-4)", "Rp 10.000"),
                    _buildRequiredOption("Mie Gacoan (Lv 6-8)", "Rp 11.000"),

                    _buildSectionHeader("Tambah Dimsum", "Opsional"),
                    _buildExtraOption("Udang Keju (isi 3)", "+Rp 9.000"),
                    _buildExtraOption("Udang Rambutan (isi 3)", "+Rp 9.000"),
                    _buildExtraOption("Lumpia Udang (isi 3)", "+Rp 9.000"),
                    _buildExtraOption("Siomay Ayam", "+Rp 9.000"),
                    _buildExtraOption("Pangsit Goreng", "+Rp 10.000"),

                    _buildSectionHeader("Pilih Minuman", "Opsional"),
                    _buildExtraOption("Es Gobak Sodor", "+Rp 9.000"),
                    _buildExtraOption("Es Teklek", "+Rp 6.000"),
                    _buildExtraOption("Es Sluku Bathok", "+Rp 6.000"),
                    _buildExtraOption("Es Petak Umpet", "+Rp 9.000"),
                    _buildExtraOption("Thai Tea", "+Rp 6.000"),

                    _buildSectionHeader("Catatan Pesanan", "Opsional"),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Contoh: Pedasnya pisah ya...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol Minus - Angka - Plus
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove, color: Colors.red),
                  ),

                  // Angka Jumlah
                  Text(
                    "$quantity",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),

                  // Tombol Tambah (+)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            // Tombol Tambah ke Keranjang
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Nanti di sini fungsi masuk ke keranjang
                },
                child: Text(
                  "Keranjang - Rp ${widget.price * quantity}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI HELPER HARUS DI LUAR Widget build() TAPI DI DALAM class ---
  Widget _buildSectionHeader(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Untuk Mie (Radio)
  Widget _buildRequiredOption(String title, String price) {
    return ListTile(
      leading: Radio<String>(
        value: title,
        groupValue: selectedMie,
        activeColor: Colors.red,
        onChanged: (value) {
          setState(() {
            selectedMie = value!;
          });
        },
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(price),
    );
  }

  // Untuk Dimsum/Minuman (Checkbox)
  Widget _buildExtraOption(String title, String price) {
    return ListTile(
      leading: Checkbox(
        value: selectedExtras.contains(title),
        activeColor: Colors.red,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              selectedExtras.add(title);
            } else {
              selectedExtras.remove(title);
            }
          });
        },
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(price),
    );
  }
}
