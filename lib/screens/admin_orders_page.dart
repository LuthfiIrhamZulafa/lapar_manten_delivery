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

  // =====================================================
  // TAMBAHKAN FUNGSI INI DI SINI
  // =====================================================
  Future<void> _updateStatusDriver(String id, String statusBaru) async {
    try {
      await _supabase
          .from('pemesanan')
          .update({'status_driver': statusBaru})
          .eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status Driver Berhasil Diubah ke $statusBaru"),
            backgroundColor: Colors.blue,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengubah status driver: $e"),
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

    if (catatanMentah.contains(':')) {
      List<String> bagian = catatanMentah.split(':');
      if (bagian.length > 1) {
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
        "Silakan konfirmasi ke admin jika orderan ini sudah siap diantar!";
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

              final String metodeBayar = pesanan['metode_pembayaran'] ?? 'COD';
              final String statusDriver =
                  pesanan['status_driver'] ?? 'Mencari Driver';

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
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Status Pengiriman:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          DropdownButton<String>(
                            value:
                                [
                                  'Mencari Driver',
                                  'Driver ke Resto',
                                  'Sedang Diantar',
                                  'Selesai',
                                ].contains(statusDriver)
                                ? statusDriver
                                : 'Mencari Driver',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            onChanged: (newValue) {
                              if (newValue != null &&
                                  newValue != statusDriver) {
                                _updateStatusDriver(idNota, newValue);
                              }
                            },
                            items:
                                <String>[
                                  'Mencari Driver',
                                  'Driver ke Resto',
                                  'Sedang Diantar',
                                  'Selesai',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      const SizedBox(height: 16),

                      // ===============================================================
                      // FITUR TERBARU: POP-UP PILIHAN DRIVER BESERTA INDIKATOR STATUS
                      // ===============================================================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // 1. Data 10 Driver Lapar Manten (Silakan sesuaikan No WA aslinya)
                            final List<Map<String, dynamic>> daftarDriver = [
                              {
                                "nama": "Driver 1 - Kace",
                                "noWA": "6282115642318",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 2 - Agi",
                                "noWA": "6282124527658",
                                "status": "Dalam Perjalanan",
                              },
                              {
                                "nama": "Driver 3 - Candra",
                                "noWA": "6281234567893",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 4 - Dedi",
                                "noWA": "6281234567894",
                                "status": "Dalam Perjalanan",
                              },
                              {
                                "nama": "Driver 5 - Eko",
                                "noWA": "6281234567895",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 6 - Fajar",
                                "noWA": "6281234567896",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 7 - Gani",
                                "noWA": "6281234567897",
                                "status": "Dalam Perjalanan",
                              },
                              {
                                "nama": "Driver 8 - Hendra",
                                "noWA": "6281234567898",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 9 - Indra",
                                "noWA": "6281234567899",
                                "status": "Standby",
                              },
                              {
                                "nama": "Driver 10 - Joko",
                                "noWA": "6281234567890",
                                "status": "Dalam Perjalanan",
                              },
                            ];

                            if (!context.mounted) return;

                            // 2. Tampilkan dialog pilihan driver saat tombol ditekan
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.motorcycle,
                                        color: Color(0xFFC60D2A),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Pilih Driver Lapar Manten",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: daftarDriver.length,
                                      itemBuilder: (BuildContext context, int i) {
                                        final String status =
                                            daftarDriver[i]["status"]!;
                                        final bool isStandby =
                                            status == "Standby";

                                        return Card(
                                          elevation: 1,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isStandby
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                              child: Icon(
                                                isStandby
                                                    ? Icons.check_circle
                                                    : Icons.delivery_dining,
                                                color: isStandby
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            title: Text(
                                              daftarDriver[i]["nama"]!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  margin: const EdgeInsets.only(
                                                    top: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isStandby
                                                        ? Colors.green[50]
                                                        : Colors.red[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    border: Border.all(
                                                      color: isStandby
                                                          ? Colors.green
                                                          : Colors.red,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isStandby
                                                          ? Colors.green[800]
                                                          : Colors.red[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey,
                                            ),
                                            onTap: () async {
                                              Navigator.pop(
                                                context,
                                              ); // Tutup dialog pop-up

                                              String nomorDriverTerpilih =
                                                  daftarDriver[i]["noWA"]!;

                                              // Buat isi pesan nota belanja
                                              final String pesanWhatsApp =
                                                  _generatePesanWA(
                                                    idNota: idNota,
                                                    tanggalOrder: tanggalOrder,
                                                    detailData:
                                                        detailPesananRaw,
                                                    namaMenuDefault: namaMenu,
                                                    jumlahDefault: jumlahPorsi,
                                                    catatanKonsumen:
                                                        catatanKonsumen,
                                                    metodeBayar: metodeBayar,
                                                    totalBayar: totalBayar,
                                                  );

                                              // Mengarahkan ke WhatsApp Driver terpilih
                                              final Uri whatsappUrl = Uri.parse(
                                                "https://wa.me/$nomorDriverTerpilih?text=${Uri.encodeComponent(pesanWhatsApp)}",
                                              );

                                              if (await canLaunchUrl(
                                                whatsappUrl,
                                              )) {
                                                await launchUrl(
                                                  whatsappUrl,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Gagal membuka WhatsApp",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
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
