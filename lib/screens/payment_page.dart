import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pilih_lokasi_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int subtotal;
  final String detailVarianYangDipilih;
  final String catatan;
  final String metodePembayaranDipilih;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.detailVarianYangDipilih,
    required this.catatan,
    required this.metodePembayaranDipilih,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  int _selectedMethodIndex = 0;

  final int _biayaLayanan = 2000;

  String _wilayahDipilih = 'dalam_kota';

  final TextEditingController _jarakController =
      TextEditingController(text: '0');

  

  int _hitungOngkir() {

  double jarakKm =
      double.tryParse(_jarakController.text) ?? 0;

  if (_wilayahDipilih == 'dalam_kota') {
    return 11000;
  } 
  
  else if (_wilayahDipilih == 'luar_wilayah') {
    return 11000 + (jarakKm * 2000).toInt();
  } 
  
  else if (_wilayahDipilih == 'luar_kota') {
    return 20000 + (jarakKm * 2000).toInt();
  }

  return 0;
}

  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil gambar: $e")),
      );
    }
  }

  void _showSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFD31124)),
                title: Text("Pilih dari Galeri", style: GoogleFonts.poppins()),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFD31124)),
                title: Text("Ambil Foto Kamera", style: GoogleFonts.poppins()),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRupiah(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    int ongkir = _hitungOngkir();

  int totalBayar =
      widget.subtotal + _biayaLayanan + ongkir;

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

            // Google Maps Pin / Wilayah Pengiriman
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AmbilLokasiPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: Text(
                        "PIN LOKASI HP (BIAR AKURAT)",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD31124),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Wilayah Pengiriman",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _wilayahDipilih,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'dalam_kota',
                        child: Text('Sumedang Kota (Rp 11.000)'),
                      ),
                      DropdownMenuItem(
                        value: 'luar_wilayah',
                        child: Text('Luar Wilayah Sumedang Kota (+Rp 2.000/km)'),
                      ),
                      DropdownMenuItem(
                        value: 'luar_kota',
                        child: Text('Luar Kota Sumedang (Rp 20.000 + Rp 2.000/km)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _wilayahDipilih = value!;
                        if (_wilayahDipilih == 'dalam_kota') {
                          _jarakController.text = '0';
                        }
                      });
                    },
                  ),
                  if (_wilayahDipilih != 'dalam_kota') ...[
                    const SizedBox(height: 12),
                    Text(
                      "Jarak Tambahan dari Batas Wilayah (KM)",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _jarakController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 5',
                        suffixText: 'KM',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Ringkasan Pembayaran",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // 2. Card Ringkasan Pesanan (Looping Semua Item & Kalkulasi Total)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Melooping daftar makanan yang dibeli dari halaman Keranjang
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];
                      int totalItemPrice = item['totalPrice'] ?? 0;
int itemQty = item['quantity'] ?? 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item['imagePath'] != null
                                  ? Image.asset(
                                      item['imagePath'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.fastfood, color: Colors.grey),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? "Paket Makanan",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "$itemQty Porsi • ${item['varian'] ?? 'Default'}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp ${_formatRupiah(totalItemPrice)}",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFD31124),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow("Subtotal Produk", widget.subtotal),
                  const SizedBox(height: 8),
                  _buildPriceRow("Biaya Layanan", _biayaLayanan),
                  const SizedBox(height: 8),
                  _buildPriceRow("Ongkos Kirim", ongkir),
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
                        "Rp ${_formatRupiah(totalBayar)}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD31124),
                          fontSize: 16,
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

            // Tab Pilihan Metode Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
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
                  _selectedMethodIndex == 0
                      ? _buildTransferBankView(totalBayar)
                      : _buildCodView(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Konfirmasi Pembayaran
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
                onPressed: _isLoading || (_selectedMethodIndex == 0 && _imageFile == null)
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          String imageUrl = "";
                          var firstItem = widget.cartItems.isNotEmpty ? widget.cartItems[0] : {};

                          if (_selectedMethodIndex == 0 && _imageFile != null) {
                            final user = Supabase.instance.client.auth.currentUser;
                            final String fileName = "${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
                            final String filePath = "public/$fileName";

                            await Supabase.instance.client.storage
                                .from('bukti_transfer')
                                .upload(filePath, _imageFile!);

                            imageUrl = Supabase.instance.client.storage
                                .from('bukti_transfer')
                                .getPublicUrl(filePath);
                          }

                          final user = Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            await Supabase.instance.client.from('pemesanan').insert({
                              'user_id': user.id,
                              'nama_menu': firstItem['name'] ?? 'Menu',
                              'jumlah': firstItem['quantity'] ?? 1,
                              'total_harga': totalBayar,
                              'status': _selectedMethodIndex == 0 ? 'Menunggu Verifikasi' : 'Pending',
                              'bukti_transfer': imageUrl,
                              'detail_pesanan': widget.detailVarianYangDipilih,
                              'catatan': widget.catatan,
                              'metode_pembayaran': _selectedMethodIndex == 0 ? 'Transfer Bank' : 'COD',
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User belum login, silakan login kembali.")),
                            );
                            return;
                          }

                          setState(() {
                            _isLoading = false;
                          });

                          if (mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Pesanan Berhasil!",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedMethodIndex == 0
                                          ? "Bukti pembayaran asli telah terkirim ke server database Admin. Pesanan Anda segera diproses!"
                                          : "Pesanan COD berhasil dibuat ke sistem database.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD31124),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        onPressed: () {
                                          widget.cartItems.clear();
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        },
                                        child: Text("Kembali ke Beranda", style: GoogleFonts.poppins(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal mengirim ke database server: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        "Konfirmasi Pembayaran",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        Text(label, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
        Text("Rp ${_formatRupiah(amount)}", style: GoogleFonts.poppins(color: Colors.black, fontSize: 13)),
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
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF005E9F), borderRadius: BorderRadius.circular(4)),
                  child: Text("BCA", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bank Central Asia (BCA)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("a.n PT Lapar Manten Group", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nomor Rekening", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                  Text(nomorRekening, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: nomorRekening));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nomor rekening disalin!")));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text("Unggah Bukti Transfer", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSelectionDialog,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text("Klik di sini untuk upload foto", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text("Format: JPG, PNG (Maks. 2MB)", style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 10)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFE0B2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text("Informasi COD", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.orange[800], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Pembayaran dilakukan secara tunai kepada kurir saat pesanan sampai di lokasi Anda. Pastikan menyiapkan uang pas sesuai dengan 'Total Bayar' di atas.",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800], height: 1.5),
          ),
        ],
      ),
    );
  }
}