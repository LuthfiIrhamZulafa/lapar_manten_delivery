import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatelessWidget {
  final VoidCallback? onGoHome;

  const OrdersPage({
    super.key,
    this.onGoHome,
  });

  String _rupiah(dynamic value) {
    final int number = int.tryParse(value.toString()) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  bool _isActiveOrder(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();
    final statusDriver = (data['status_driver'] ?? '').toString().toLowerCase();

    return !status.contains('selesai') &&
        !status.contains('dibatalkan') &&
        !statusDriver.contains('selesai');
  }

  String _statusText(Map<String, dynamic> data) {
    final statusDriver = data['status_driver'] ?? 'Mencari Driver';

    if (statusDriver == 'Mencari Driver') {
      return 'Kurir sedang dicari';
    } else if (statusDriver == 'Driver ke Resto') {
      return 'Kurir menuju resto';
    } else if (statusDriver == 'Sedang Diantar') {
      return 'Kurir sedang menuju lokasi Anda';
    } else {
      return statusDriver.toString();
    }
  }

  double _progressValue(Map<String, dynamic> data) {
    final statusDriver = data['status_driver'] ?? 'Mencari Driver';

    if (statusDriver == 'Mencari Driver') return 0.25;
    if (statusDriver == 'Driver ke Resto') return 0.50;
    if (statusDriver == 'Sedang Diantar') return 0.75;
    if (statusDriver == 'Selesai') return 1.0;

    return 0.20;
  }

  Widget _menuImage(String? imagePath, double size) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey[300],
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Icon(Icons.fastfood, color: Colors.grey),
          );
        },
      );
    }

    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: const Icon(Icons.fastfood, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Silakan login terlebih dahulu"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "ORDERS",
          style: GoogleFonts.poppins(
            color: const Color(0xFFD31124),
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('pemesanan')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat pesanan: ${snapshot.error}"),
            );
          }

          final data = snapshot.data ?? [];

          final activeOrders = data.where(_isActiveOrder).toList();
          final historyOrders = data.where((item) => !_isActiveOrder(item)).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sedang Diproses",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activeOrders.isEmpty
                      ? "Tidak ada pesanan aktif"
                      : "Pesanan Anda sedang kami siapkan",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                if (activeOrders.isNotEmpty)
                  _activeOrderCard(activeOrders.first)
                else
                  _emptyActiveCard(),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Riwayat Pesanan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Filter",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD31124),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.tune,
                          color: Color(0xFFD31124),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (historyOrders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "Belum ada riwayat pesanan",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...historyOrders.map(
  (item) => _historyCard(context, item),
),
              ],
            ),
          );
        },
      ),
      
    );
  }

  Widget _emptyActiveCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(
        "Pesanan aktif akan muncul di sini.",
        style: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
    );
  }

  Widget _activeOrderCard(Map<String, dynamic> item) {
    final namaMenu = item['nama_menu'] ?? 'Menu';
    final jumlah = item['jumlah'] ?? 1;
    final total = item['total_harga'] ?? 0;
    final gambar = item['gambar_menu']?.toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: _menuImage(gambar, 85),
    ),

    const SizedBox(width: 16),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaMenu,
            style: GoogleFonts.poppins(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "$jumlah Item • Rp ${_rupiah(total)}",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: Color(0xFFD31124),
                  size: 20,
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    _statusText(item),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD31124),
                      fontSize: 14,
                    ),
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
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressValue(item),
              minHeight: 9,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD31124)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(
  BuildContext context,
  Map<String, dynamic> item,
) {
    final namaMenu = item['nama_menu'] ?? 'Menu';
    final jumlah = item['jumlah'] ?? 1;
    final total = item['total_harga'] ?? 0;
    final gambar = item['gambar_menu']?.toString();
    final status = item['status_driver'] ?? item['status'] ?? 'Selesai';

    final createdAt = item['created_at'] != null
        ? DateTime.parse(item['created_at']).toLocal()
        : DateTime.now();

    final tanggal =
        "${createdAt.day}/${createdAt.month}/${createdAt.year}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

    final isCancelled = status.toString().toLowerCase().contains('batal');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                tanggal,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? const Color(0xFFF1F1F1)
                      : const Color(0xFFE9FFF1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isCancelled ? "Dibatalkan" : "Selesai",
                  style: GoogleFonts.poppins(
                    color: isCancelled ? Colors.grey : Colors.green,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _menuImage(gambar, 65),
              ),
              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaMenu,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "$jumlah Porsi",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "Rp ${_rupiah(total)}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (!isCancelled) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
  child: ElevatedButton(
    onPressed: () {
      onGoHome?.call();
    },
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFFFFE9E9),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: Text(
      "Pesan Lagi",
      style: GoogleFonts.poppins(
        color: const Color(0xFFD31124),
        fontSize: 16,
      ),
    ),
  ),
),
              ],
            ),
          ],
        ],
      ),
    );
  }
}