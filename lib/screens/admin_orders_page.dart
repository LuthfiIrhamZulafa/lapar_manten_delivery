import 'dart:convert';
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

  Future<List<Map<String, dynamic>>> _getAllPesananMasuk() async {
    final response = await _supabase
        .from('pemesanan')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _updateStatusPesanan(String id, String statusBaru) async {
    try {
      await _supabase
          .from('pemesanan')
          .update({'status': statusBaru})
          .eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status Berhasil Diubah ke $statusBaru"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengubah status: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // PERBAIKAN 1: Fungsi Pembersih Catatan (Hanya Mengambil Isi Catatan Pembeli)
  // ===========================================================================
  String _bersihkanCatatan(String catatanMentah) {
    if (catatanMentah.isEmpty || catatanMentah == 'Tidak ada catatan khusus') {
      return 'Tidak ada catatan khusus';
    }

    // Jika formatnya "Nama Resto: Catatan Pembeli", kita belah berdasarkan tanda ":"
    if (catatanMentah.contains(':')) {
      List<String> bagian = catatanMentah.split(':');
      if (bagian.length > 1) {
        // Menggabungkan sisa potongan teks setelah ":" dan membuang spasi kosong di depan/belakang
        String hasilCatatan = bagian.sublist(1).join(':').trim();
        return hasilCatatan.isNotEmpty
            ? hasilCatatan
            : 'Tidak ada catatan khusus';
      }
    }
    return catatanMentah;
  }

  Widget _buildDetailPesanan(
    dynamic detailData,
    String namaMenuDefault,
    String jumlahDefault,
  ) {
    if (detailData == null) {
      return Text(
        "• $namaMenuDefault ($jumlahDefault Porsi)",
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      );
    }

    try {
      List<dynamic> listMenu = [];
      if (detailData is String) {
        listMenu = jsonDecode(detailData);
      } else if (detailData is List) {
        listMenu = detailData;
      } else {
        return Text(
          "• $detailData",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listMenu.map<Widget>((item) {
          final nama = item['nama_menu'] ?? item['nama'] ?? 'Menu';
          final qty = item['jumlah'] ?? item['qty'] ?? 1;
          final catatanItem = item['catatan'] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• $nama x$qty",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (catatanItem.toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      "└ Variasi/Catatan: $catatanItem",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    } catch (e) {
      return Text("• $detailData", style: const TextStyle(fontSize: 14));
    }
  }

  String _generatePesanWA({
    required String idNota,
    required String tanggalOrder,
    required dynamic detailData,
    required String namaMenuDefault,
    required String jumlahDefault,
    required String catatanKonsumen,
    required String metodeBayar,
    required String totalBayar,
  }) {
    String daftarMenuTeks = "";

    try {
      List<dynamic> listMenu = (detailData is String)
          ? jsonDecode(detailData)
          : (detailData as List);
      for (var item in listMenu) {
        final nama = item['nama_menu'] ?? item['nama'] ?? 'Menu';
        final qty = item['jumlah'] ?? item['qty'] ?? 1;
        daftarMenuTeks += "• $nama ($qty Porsi)\n";
      }
    } catch (e) {
      daftarMenuTeks =
          "• $namaMenuDefault ($jumlahDefault Porsi)\nDetail: $detailData\n";
    }

    return "📢 *ORDERAN LAPAR MANTEN BARU!*\n\n"
        "🆔 *Nota:* #$idNota\n"
        "⏰ *Waktu Order:* $tanggalOrder\n\n"
        "🍽️ *Rincian Pesanan:*\n$daftarMenuTeks\n"
        "📌 *Catatan :* $catatanKonsumen\n\n"
        "💳 *Metode Pembayaran:* $metodeBayar\n"
        "💰 *Total Bayar:* Rp $totalBayar\n\n"
        "Silakan konfirmasi di grup jika siap mengambil orderan ini!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesanan Masuk (Admin)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC60D2A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
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
                "Belum ada pesanan masuk.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: listPesanan.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final pesanan = listPesanan[index];

              final String idNota = pesanan['id'].toString();
              final String statusBayar = pesanan['status'] ?? 'Pending';
              final String tanggalOrder = pesanan['created_at'] != null
                  ? DateTime.parse(
                      pesanan['created_at'],
                    ).toLocal().toString().substring(0, 16)
                  : '-';

              final dynamic detailPesananRaw = pesanan['detail_pesanan'];
              final String namaMenu = pesanan['nama_menu'] ?? 'Menu Makanan';
              final String jumlahPorsi = (pesanan['jumlah'] ?? 1).toString();
              final String totalBayar = (pesanan['total_harga'] ?? 0)
                  .toString();

              // ===============================================================
              // PERBAIKAN 2: Membaca kolom metode_pembayaran yang baru dibuat
              // ===============================================================
              final String metodeBayar = pesanan['metode_pembayaran'] ?? 'COD';

              // Memanggil fungsi pembersih catatan
              final String catatanKonsumen = _bersihkanCatatan(
                pesanan['catatan'] ?? 'Tidak ada catatan khusus',
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                color: statusBayar == 'Pending'
                    ? Colors.amber[50]
                    : Colors.white,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order ID: #$idNota",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Waktu: $tanggalOrder",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (statusBayar == 'Pending') ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "BARU",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value:
                                      ['Pending', 'Lunas'].contains(statusBayar)
                                      ? statusBayar
                                      : 'Pending',
                                  style: TextStyle(
                                    color: statusBayar == 'Lunas'
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  onChanged: (newValue) {
                                    if (newValue != null &&
                                        newValue != statusBayar) {
                                      _updateStatusPesanan(idNota, newValue);
                                    }
                                  },
                                  items: <String>['Pending', 'Lunas']
                                      .map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: value == 'Lunas'
                                                  ? Colors.green[100]
                                                  : Colors.orange[100],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(value),
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),

                      const Text(
                        "Rincian Menu:",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      _buildDetailPesanan(
                        detailPesananRaw,
                        namaMenu,
                        jumlahPorsi,
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "💬 Catatan Utama: $catatanKonsumen",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Divider(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Metode: $metodeBayar",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "Total: Rp $totalBayar",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC60D2A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final String pesanWhatsApp = _generatePesanWA(
                              idNota: idNota,
                              tanggalOrder: tanggalOrder,
                              detailData: detailPesananRaw,
                              namaMenuDefault: namaMenu,
                              jumlahDefault: jumlahPorsi,
                              catatanKonsumen: catatanKonsumen,
                              metodeBayar: metodeBayar,
                              totalBayar: totalBayar,
                            );

                            final Uri whatsappUrl = Uri.parse(
                              "https://wa.me/?text=${Uri.encodeComponent(pesanWhatsApp)}",
                            );

                            if (await canLaunchUrl(whatsappUrl)) {
                              await launchUrl(
                                whatsappUrl,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Gagal membuka WhatsApp"),
                                  ),
                                );
                              }
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
