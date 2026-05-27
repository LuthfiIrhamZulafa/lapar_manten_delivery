import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // FUNGSI UTAMA: Mengambil SEMUA pesanan dari tabel database untuk Admin
  Future<List<Map<String, dynamic>>> _getAllPesananMasuk() async {
    final response = await _supabase
        .from('pemesanan') // Menggunakan nama tabel kamu
        .select()
        .order('created_at', ascending: false); // Pesanan terbaru paling atas

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesanan Masuk (Admin)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC60D2A), // Merah Lapar Manten
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllPesananMasuk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFC60D2A)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
          }

          final listPesanan = snapshot.data ?? [];

          if (listPesanan.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada pesanan masuk dari pelanggan.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: listPesanan.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final pesanan = listPesanan[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: #${pesanan['id']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          // Status Pesanan
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pesanan['status'] == 'Lunas'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pesanan['status'] ?? 'Pending',
                              style: TextStyle(
                                color: pesanan['status'] == 'Lunas'
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Data pesanan
                            final String idNota = pesanan['id'].toString();
                            final String namaMenu =
                                pesanan['nama_menu'] ?? 'Menu';
                            final String jumlahPorsi = pesanan['jumlah']
                                .toString();
                            final String totalBayar = pesanan['total_harga']
                                .toString();

                            // Pesan otomatis WhatsApp
                            final String pesanWhatsApp =
                                "📢 *ORDERAN LAPAR MANTEN BARU!*\n\n"
                                "🆔 Nota: #$idNota\n"
                                "🍽️ Menu: $namaMenu\n"
                                "📦 Jumlah: $jumlahPorsi Porsi\n"
                                "💰 Total Bayar: Rp $totalBayar\n\n"
                                "Silakan konfirmasi di grup jika siap mengambil orderan ini!";

                            // Link WhatsApp
                            final Uri whatsappUrl = Uri.parse(
                              "https://wa.me/?text=${Uri.encodeComponent(pesanWhatsApp)}",
                            );

                            // Buka WhatsApp
                            if (await canLaunchUrl(whatsappUrl)) {
                              await launchUrl(
                                whatsappUrl,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Gagal membuka WhatsApp"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            "BAGIKAN KE WA DRIVER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        pesanan['nama_menu'] ?? 'Menu Makanan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Jumlah: ${pesanan['jumlah'] ?? 1} porsi",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Pendapatan:",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "Rp ${pesanan['total_harga'] ?? 0}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC60D2A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
