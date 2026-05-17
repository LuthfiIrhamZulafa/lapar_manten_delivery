import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailFoodPage extends StatefulWidget {
  final String name;
  final String imagePath;
  final String description;
  final List<Map<String, dynamic>> varianList;
  final List<Map<String, dynamic>> tambahanList;

  const DetailFoodPage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.varianList,
    required this.tambahanList,
    required this.description,
  });

  @override
  State<DetailFoodPage> createState() => _DetailFoodPageState();
}

class _DetailFoodPageState extends State<DetailFoodPage> {
  int quantity = 1;

  String selectedMie = ""; // Untuk menyimpan mie yang dipilih
  List<String> selectedExtras = []; // Untuk menyimpan daftar dimsum/minuman
  int priceMie = 0; // Untuk menyimpan harga mie yang dipilih
  int priceExtras = 0; // Untuk menyimpan total harga semua tambahan

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
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),

                    // SECTION VARIAN
                    _buildSectionHeader(
                      "Pilih Varian",
                      "Wajib dipilih salah satu",
                    ),
                    const SizedBox(height: 10),

                    ...widget.varianList.map((varian) {
                      return _buildRequiredOption(
                        varian['name'],
                        varian['price'],
                        "Rp ${varian['price']}",
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // SECTION TAMBAHAN
                    _buildSectionHeader("Menu Tambahan", "Opsional"),
                    const SizedBox(height: 10),

                    ...widget.tambahanList.map((tambahan) {
                      return _buildExtraOption(
                        tambahan['name'],
                        tambahan['price'],
                        "+Rp ${tambahan['price']}",
                      );
                    }).toList(),

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
                  backgroundColor: selectedMie.isEmpty
                      ? Colors.grey
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                // Tombol hanya aktif jika mie sudah dipilih
                onPressed: selectedMie.isEmpty
                    ? null
                    : () {
                        // Fungsi masuk keranjang nanti di sini
                      },

                child: Text(
                  selectedMie.isEmpty
                      ? "Pilih Varian Terlebih Dahulu"
                      : "Keranjang - Rp ${(priceMie + priceExtras) * quantity}",

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
  Widget _buildRequiredOption(
    String title,
    int priceValue,
    String priceDisplay,
  ) {
    return ListTile(
      leading: Radio<String>(
        value: title,
        groupValue: selectedMie,
        activeColor: Colors.red,
        onChanged: (value) {
          setState(() {
            selectedMie = value!;
            priceMie =
                priceValue; // Harga mie langsung ter-update sesuai pilihan
          });
        },
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(
        priceDisplay,
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }

  // Untuk Dimsum/Minuman (Checkbox)
  Widget _buildExtraOption(String title, int priceValue, String priceDisplay) {
    return ListTile(
      leading: Checkbox(
        value: selectedExtras.contains(title),
        activeColor: Colors.red,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              selectedExtras.add(title);
              priceExtras +=
                  priceValue; // Kalau dicentang, harga tambahan bertambah
            } else {
              selectedExtras.remove(title);
              priceExtras -=
                  priceValue; // Kalau dicentang dilepas, harga tambahan berkurang
            }
          });
        },
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(
        priceDisplay,
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }
}
