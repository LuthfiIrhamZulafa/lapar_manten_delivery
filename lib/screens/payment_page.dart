import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pilih_lokasi_page.dart';
import 'package:latlong2/latlong.dart' as lt;
import 'map_selection_widget.dart';
import '../services/location_security_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';



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

class _PaymentPageState extends State<PaymentPage>
    with WidgetsBindingObserver {
  final LocationSecurityService _locationSecurity = LocationSecurityService();
  final TextEditingController _namaPenerimaController = TextEditingController();
  final TextEditingController _noHpPenerimaController = TextEditingController();
  final TextEditingController _patokanManualController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _detailAlamatSendiriController = TextEditingController();
  final TextEditingController _namaPenerimaSendiriController = TextEditingController();
  final TextEditingController _noHpPenerimaSendiriController = TextEditingController();

  double? userLat;
  double? userLng;
  bool isUsingFakeGps = false;
  bool _deviceBlocked = false;
  bool _kirimKeOrangLain = false;
  StreamSubscription<Position>? _positionSubscription;
  String _alamatTujuanLain = "";
  double? _customLat;
  double? _customLng;
  bool _dialogFakeGpsSedangTampil = false;
  bool _nomorHpValid(String nomorHp) {
  final String angka = nomorHp.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  return angka.length >= 10 &&
      angka.length <= 15;
}

bool get _dataPenerimaLengkap {
  // Pesanan untuk diri sendiri.
  if (!_kirimKeOrangLain) {
    return _namaPenerimaSendiriController
            .text
            .trim()
            .isNotEmpty &&
        _nomorHpValid(
          _noHpPenerimaSendiriController.text,
        ) &&
        _detailAlamatSendiriController
            .text
            .trim()
            .isNotEmpty;
  }

  // Pesanan untuk orang lain.
  return _namaPenerimaController
          .text
          .trim()
          .isNotEmpty &&
      _nomorHpValid(
        _noHpPenerimaController.text,
      ) &&
      _alamatController.text.trim().isNotEmpty &&
      _patokanManualController
          .text
          .trim()
          .isNotEmpty &&
      _customLat != null &&
      _customLng != null;
}

  int _selectedMethodIndex = 0;

// Mencegah pilihan pengguna ditimpa proses loading Supabase.
bool _metodeDiubahManual = false;

final int _biayaLayanan = 2000;



  final TextEditingController _jarakController = TextEditingController(
    text: '0',
  );


  lt.LatLng _currentLocation = const lt.LatLng(
    -6.8587,
    107.9194,
  ); // Default Sumedang Kota
  // List koordinat pembentuk batas area Sumedang Kota (Poligon)
  final List<lt.LatLng> _batasSumedangKota = const [
    lt.LatLng(-6.826628, 107.918180), // Titik jembatan bojong
    lt.LatLng(-6.826399, 107.922639), // Titik perempatan jatihurip
    lt.LatLng(-6.834942, 107.930769), // Titik bundaran alamsari
    lt.LatLng(-6.840782, 107.934744), // Titik jembatan dano
    lt.LatLng(-6.849795, 107.932911), // Titik jembatan tegalkalong
    lt.LatLng(-6.855750, 107.931398), // titik talun
    lt.LatLng(-6.859139, 107.924645), // titik jembatan cipameungpeuk
    lt.LatLng(-6.860450, 107.916264), // titik binokasih
    lt.LatLng(-6.849605, 107.912057), // titik kutamaya
  ];

 void _tampilkanPeringatanFakeGps() {

  if (_dialogFakeGpsSedangTampil) return;

  _dialogFakeGpsSedangTampil = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("⚠️ Peringatan Keamanan"),
      content: const Text(
        "Fake GPS terdeteksi. Matikan Fake GPS untuk melanjutkan.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);

            _dialogFakeGpsSedangTampil = false;
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

Widget _buildFormAlamatTujuanLain() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "👤 Data Penerima",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFFD31124),
        ),
      ),
      const SizedBox(height: 10),

      // Nama penerima
      TextFormField(
        controller: _namaPenerimaController,
        onChanged: (value) {
  setState(() {});
},
        decoration: const InputDecoration(
          labelText: "Nama Penerima",
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 10),

      // Nomor HP penerima
      TextFormField(
        controller: _noHpPenerimaController,
        onChanged: (value) {
  setState(() {});
},
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: "Nomor HP / WhatsApp Penerima",
          prefixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 15),

      const Text(
        "📍 Alamat Tujuan Pengantaran",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 8),

      TextFormField(
  controller: _alamatController,
  readOnly: true,
  onChanged: (value) {
    setState(() {});
  },
  decoration: InputDecoration(
    labelText: "Alamat Tujuan",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    suffixIcon: const Icon(
      Icons.map,
      color: Color(0xFFE52727),
    ),
  ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmbilLokasiPage(
  initialLat: _customLat,
  initialLng: _customLng,
),
            ),
          );

          if (result != null) {
setState(() {
  _alamatTujuanLain = result['alamat_teks'];
  _alamatController.text = result['alamat_teks'];

  _customLat = result['latitude'];
  _customLng = result['longitude'];

  _currentLocation = lt.LatLng(
    _customLat!,
    _customLng!,
  );
});

_updateOngkir();
}
        },
      ),

      const SizedBox(height: 10),

      // Patokan rumah
      TextFormField(
        controller: _patokanManualController,
        maxLines: 2,
        onChanged: (value) {
  setState(() {});
},
        decoration: const InputDecoration(
          labelText: "Detail Alamat Tambahan / Patokan",
          hintText:
              "Contoh: Blok C No 12, pagar hitam dekat Masjid Al Ikhlas",
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );
}

int _ubahMetodeMenjadiIndex(
  String? metode,
) {
  final String value =
      metode?.trim().toLowerCase() ?? '';

  if (value == 'cod' ||
      value.contains('bayar di tempat')) {
    return 1;
  }

  return 0;
}

Future<void>
    _ambilMetodePembayaranDefault() async {
  final User? user =
      Supabase.instance.client.auth.currentUser;

  if (user == null) {
    return;
  }

  try {
    final Map<String, dynamic>? data =
        await Supabase.instance.client
            .from('users')
            .select(
              'metode_pembayaran_default',
            )
            .eq('id', user.id)
            .maybeSingle();

    final String? metodeDefault =
        data?['metode_pembayaran_default']
            ?.toString();

    if (!mounted ||
        _metodeDiubahManual) {
      return;
    }

    setState(() {
      _selectedMethodIndex =
          _ubahMetodeMenjadiIndex(
        metodeDefault,
      );
    });

    debugPrint(
      "METODE PEMBAYARAN UTAMA: "
      "$metodeDefault",
    );
  } catch (e) {
    // Jika gagal membaca Supabase,
    // gunakan nilai yang dikirim halaman sebelumnya.
    debugPrint(
      "Gagal membaca metode utama: $e",
    );
  }
}

@override
void initState() {
  super.initState();

  // Gunakan pilihan dari halaman sebelumnya sebagai nilai sementara.
  _selectedMethodIndex =
      _ubahMetodeMenjadiIndex(
    widget.metodePembayaranDipilih,
  );

  // Kemudian baca metode utama yang disimpan di profil.
  _ambilMetodePembayaranDefault();

  // Mendaftarkan observer lifecycle aplikasi.
  WidgetsBinding.instance.addObserver(this);

  // Cek keamanan saat halaman pertama kali dibuka
  _cekKeamananLokasi();

  // Mulai monitoring lokasi secara realtime
  _startRealtimeLocationMonitoring();

  // Hitung ongkir setelah widget selesai dibuat
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _updateOngkir();
  });
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (state == AppLifecycleState.resumed) {
    await _cekKeamananLokasi();
  }
}

void _startRealtimeLocationMonitoring() {
  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    ),
  ).listen((Position position) async {
    final hasil =
        await _locationSecurity.evaluateLocation(position);

    final bool blocked =
        hasil['blocked'] == true;

    if (!mounted) return;

    if (blocked) {
       _deviceBlocked = true;
      if (!isUsingFakeGps) {
        setState(() {
          isUsingFakeGps = true;
          userLat = 0;
          userLng = 0;
        });

        _tampilkanPeringatanFakeGps();
      }

      return;
    }
    if (_deviceBlocked || isUsingFakeGps) {
  return;
}

    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;

      _currentLocation = lt.LatLng(
        position.latitude,
        position.longitude,
      );
    });

    _updateOngkir();
  });
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _positionSubscription?.cancel();
  _namaPenerimaController.dispose();
  _noHpPenerimaController.dispose();
  _patokanManualController.dispose();
  _alamatController.dispose();
  _detailAlamatSendiriController.dispose();
  _namaPenerimaSendiriController.dispose();
  _noHpPenerimaSendiriController.dispose();

  super.dispose();
}


 

void _updateOngkir() {
  setState(() {
    _ongkir = _hitungOngkir();
  });
}

 int _hitungOngkir() {
  int tarifDasarSumedangKota = 11000;
  int tarifPerKmLuarKota = 2000;

  final lt.LatLng lokasiTujuan =
      _kirimKeOrangLain &&
              _customLat != null &&
              _customLng != null
          ? lt.LatLng(_customLat!, _customLng!)
          : _currentLocation;

    // 1. Cek secara realtime apakah koordinat user ada di dalam wilayah poligon
    bool diDalamKota = _isInsideSumedangKota(
  lokasiTujuan,
  _batasSumedangKota,
);
    if (diDalamKota) {
      // Jika di dalam poligon, kunci dropdown ke 'dalam_kota' dan jarak 0
      
      return tarifDasarSumedangKota;
    } else {
      // 2. Jika di luar poligon, hitung jarak dari batas poligon terdekat yang searah jalan
  double jarakLuarKotaKm =
    _hitungJarakDariBatasTerdekat(
      lokasiTujuan,
      _batasSumedangKota,
    );


_jarakController.text =
    jarakLuarKotaKm.toStringAsFixed(2);

int kilometerDitagihkan = jarakLuarKotaKm.ceil();

int biayaTambahan =
    kilometerDitagihkan * tarifPerKmLuarKota;

return tarifDasarSumedangKota + biayaTambahan;
    }
  }

  File? _imageFile;
  int _ongkir = 11000;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil gambar: $e")));
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
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFD31124),
                ),
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
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // ==================== CODINGAN LOGIKA GEOMETRI AUTOMATIC SHIPPING ====================

  // 1. Fungsi cek apakah koordinat di dalam area Sumedang Kota (Ray-Casting Algorithm)
  bool _isInsideSumedangKota(lt.LatLng point, List<lt.LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;
    double x = point.longitude;
    double y = point.latitude;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < y && polygon[j].latitude >= y ||
              polygon[j].latitude < y && polygon[i].latitude >= y) &&
          (polygon[i].longitude <= x || polygon[j].longitude <= x)) {
        if (polygon[i].longitude +
                (y - polygon[i].latitude) /
                    (polygon[j].latitude - polygon[i].latitude) *
                    (polygon[j].longitude - polygon[i].longitude) <
            x) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }
    return oddNodes;
  }

  // 2. Fungsi hitung jarak antara dua koordinat dalam satuan Kilometer (Haversine Formula)
  double _hitungJarakKm(lt.LatLng p1, lt.LatLng p2) {
    const double bumiRadius = 6371.0; // radius bumi dalam km
    double dLat = (p2.latitude - p1.latitude) * (3.141592653589793 / 180);
    double dLon = (p2.longitude - p1.longitude) * (3.141592653589793 / 180);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * (3.141592653589793 / 180)) *
            math.cos(p2.latitude * (3.141592653589793 / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return bumiRadius * c;
  }

  // 3. Fungsi mencari jarak terdekat dari lokasi user luar kota ke benteng batas poligon
  double _hitungJarakDariBatasTerdekat(
    lt.LatLng userLoc,
    List<lt.LatLng> polygon,
  ){
    double jarakMin = double.infinity;

    for (int i = 0; i < polygon.length; i++) {
      lt.LatLng p1 = polygon[i];
      lt.LatLng p2 = polygon[(i + 1) % polygon.length];

      double jarak = _jarakKeGarisSisi(userLoc, p1, p2);
      if (jarak < jarakMin) {
        jarakMin = jarak;
      }
    }
    return jarakMin;
  }



  // 4. Fungsi pembantu matematika proyeksi titik ke garis
  double _jarakKeGarisSisi(lt.LatLng p, lt.LatLng a, lt.LatLng b) {
    double x = p.longitude, y = p.latitude;
    double x1 = a.longitude, y1 = a.latitude;
    double x2 = b.longitude, y2 = b.latitude;

    double dx = x2 - x1;
    double dy = y2 - y1;

    if (dx == 0 && dy == 0) return _hitungJarakKm(p, a);

    double t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);

    if (t < 0) return _hitungJarakKm(p, a);
    if (t > 1) return _hitungJarakKm(p, b);

    lt.LatLng titikProyeksi = lt.LatLng(y1 + t * dy, x1 + t * dx);
    return _hitungJarakKm(p, titikProyeksi);
  }

  Future<void> _cekKeamananLokasi() async {
    final result = await _locationSecurity.checkLocation();

    setState(() {
  userLat = result['latitude'];
  userLng = result['longitude'];
  isUsingFakeGps = false;

  _currentLocation = lt.LatLng(
    userLat!,
    userLng!,
  );
});

_updateOngkir();
  }

  void kirimLinkLokasi(String orderId) {
    String link = "https://laparmanten.com/location/$orderId";

    print(link);
  }

  @override
  Widget build(BuildContext context) {
    int ongkir = _ongkir;
    int totalBayar = widget.subtotal + _biayaLayanan + ongkir;

    return Scaffold(
  resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(
    Icons.arrow_back,
    color: Colors.black,
  ),
  onPressed: () {
    if (_kirimKeOrangLain) {
      // Kembali dari form penerima ke PaymentPage
      setState(() {
        _kirimKeOrangLain = false;

        _customLat = null;
        _customLng = null;
        _alamatTujuanLain = "";

        _alamatController.clear();
        _patokanManualController.clear();
        _namaPenerimaController.clear();
        _noHpPenerimaController.clear();

        // Kembali menggunakan lokasi GPS customer
        if (userLat != null && userLng != null) {
          _currentLocation = lt.LatLng(
            userLat!,
            userLng!,
          );
        }
      });

      _updateOngkir();
    } else {
      // Jika sudah berada di PaymentPage, kembali ke keranjang
      Navigator.pop(context);
    }
  },
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
      body: SafeArea(
  child: SingleChildScrollView(
    keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
    children: [
          // MAPS DI ATAS SEPEREMPAT LAYAR (Dengan indikator loading jika GPS sedang mencari posisi)
          _kirimKeOrangLain
              ? _buildFormAlamatTujuanLain()
              : MapSelectionWidget(
  locationSecurityService: _locationSecurity,
  onLocationSelected:
      (lat, lng, blocked, fakeGps, teleport, accuracy) async {
    final bool isBadLocation =
        blocked || fakeGps || teleport;

    if (!mounted) return;

    setState(() {
      userLat = lat;
      userLng = lng;
      isUsingFakeGps = isBadLocation;

      // Koordinat hanya diperbarui jika GPS aman
      if (!isBadLocation && lat != 0.0 && lng != 0.0) {
        _currentLocation = lt.LatLng(lat, lng);
      }
    });

    if (isBadLocation) {
      _tampilkanPeringatanFakeGps();
      return;
    }

    _updateOngkir();
  },
),

// DATA PENERIMA UNTUK PESANAN DIRI SENDIRI
if (!_kirimKeOrangLain)
  Padding(
    padding: const EdgeInsets.fromLTRB(
      16,
      16,
      16,
      8,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data Penerima",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Nama penerima
        TextFormField(
          controller:
              _namaPenerimaSendiriController,
          textCapitalization:
              TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: "Nama Penerima",
            hintText: "Masukkan nama penerima",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Color(0xFFD31124),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  const BorderSide(
                color: Color(0xFFD31124),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Nomor HP penerima
        TextFormField(
          controller:
              _noHpPenerimaSendiriController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter
                .digitsOnly,
            LengthLimitingTextInputFormatter(
              15,
            ),
          ],
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText:
                "Nomor HP / WhatsApp Penerima",
            hintText: "Contoh: 082112345678",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFFD31124),
            ),
            errorText:
                _noHpPenerimaSendiriController
                            .text
                            .isNotEmpty &&
                        !_nomorHpValid(
                          _noHpPenerimaSendiriController
                              .text,
                        )
                    ? "Nomor HP harus 10–15 digit"
                    : null,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  const BorderSide(
                color: Color(0xFFD31124),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "Detail Alamat Pengantaran",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller:
              _detailAlamatSendiriController,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText:
                "Detail Alamat / Patokan",
            hintText:
                "Contoh: Rumah cokelat, pagar hitam, samping masjid",
            alignLabelWithHint: true,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.home_outlined,
              color: Color(0xFFD31124),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  const BorderSide(
                color: Color(0xFFD31124),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  ),

const SizedBox(height: 4),

// TOMBOL KIRIM KE ORANG TERDEKAT
if (!_kirimKeOrangLain)
  Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _kirimKeOrangLain = true;
          });

          _updateOngkir();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE52727),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Kirim ke Orang Terdekat",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
          // BAGIAN FORM PEMBAYARAN
         Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                                 
                  Text(
                    "Ringkasan Pembayaran",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Card Ringkasan Pesanan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
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
                                            child: const Icon(
                                              Icons.fastfood,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
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
                 if (!_dataPenerimaLengkap)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0F1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFFFCDD2),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFD31124),
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _kirimKeOrangLain
    ? "Lengkapi nama penerima, nomor HP, alamat tujuan, dan detail alamat terlebih dahulu."
    : "Lengkapi nama penerima, nomor HP yang valid, dan detail alamat terlebih dahulu.",
            style: GoogleFonts.poppins(
              color: const Color(0xFFD31124),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ),
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
                      onPressed:
    isUsingFakeGps ||
        userLat == 0.0 ||
        userLat == null ||
        !_dataPenerimaLengkap ||
        _isLoading ||
        (_selectedMethodIndex == 0 && _imageFile == null)
    ? null
    : () async {
                              
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                // =======================
// CEK KEAMANAN PERANGKAT
// =======================

// Ambil posisi terbaru langsung dari GPS
if (userLat == null || userLng == null) {
  setState(() {
    _isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Lokasi belum tersedia."),
    ),
  );
  return;
}

final posisiTerbaru = Position(
  latitude: userLat!,
  longitude: userLng!,
  timestamp: DateTime.now(),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

// Cek keamanan menggunakan posisi terbaru
final hasilKeamanan =
    await _locationSecurity.checkLocationSecurity(
  posisiTerbaru,
);

int skorRisikoPerangkat =
    hasilKeamanan['risk'] ?? 0;

if (skorRisikoPerangkat >= 70) {
  setState(() {
    _isLoading = false;
  });

  _tampilkanPeringatanFakeGps();
  return;
}
                                String imageUrl = "";
                                double latitudeTujuan =
    _kirimKeOrangLain
        ? (_customLat ?? posisiTerbaru.latitude)
        : posisiTerbaru.latitude;

double longitudeTujuan =
    _kirimKeOrangLain
        ? (_customLng ?? posisiTerbaru.longitude)
        : posisiTerbaru.longitude;

String alamatLengkapPengiriman =
    _kirimKeOrangLain
        ? "${_alamatTujuanLain.trim()}. "
            "Patokan: ${_patokanManualController.text.trim()}"
        : "Lokasi GPS Customer. "
            "Detail alamat: ${_detailAlamatSendiriController.text.trim()}";
                                String orderId =
                                    "LM-${DateTime.now().millisecondsSinceEpoch}";
                                
                                var firstItem = widget.cartItems.isNotEmpty
                                    ? widget.cartItems[0]
                                    : {};

                                if (_selectedMethodIndex == 0 &&
                                    _imageFile != null) {
                                  final user =
                                      Supabase.instance.client.auth.currentUser;
                                  final String fileName =
                                      "${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
                                  final String filePath = "public/$fileName";

                                  await Supabase.instance.client.storage
                                      .from('bukti_transfer')
                                      .upload(filePath, _imageFile!);

                                  imageUrl = Supabase.instance.client.storage
                                      .from('bukti_transfer')
                                      .getPublicUrl(filePath);
                                }

                                final user =
                                    Supabase.instance.client.auth.currentUser;
                                if (user != null) {
                                  await Supabase.instance.client
                                      .from('pemesanan')
                                      .insert({
                                        'order_id': orderId,
                                        'user_id': user.id,
                                        'gambar_menu': firstItem['imagePath'] ?? '',
                                        'nama_menu':
                                            firstItem['name'] ?? 'Menu',
                                        'jumlah': firstItem['quantity'] ?? 1,
                                        'total_harga': totalBayar,
                                        'status': _kirimKeOrangLain
                                            ? 'Menunggu Verifikasi Penerima'
                                            : _selectedMethodIndex == 0
                                            ? 'Menunggu Verifikasi'
                                            : 'Pending',
                                        'bukti_transfer': imageUrl,
                                        'detail_pesanan':
                                            widget.detailVarianYangDipilih,
                                        'catatan': widget.catatan,
                                        'metode_pembayaran':
                                            _selectedMethodIndex == 0
                                            ? 'Transfer Bank'
                                            : 'COD',
                                       'latitude_tujuan': latitudeTujuan,
                                       'longitude_tujuan': longitudeTujuan,                                       
                                            'risk_score_customer': skorRisikoPerangkat,
                                         'tipe_pengiriman':
                                          _kirimKeOrangLain
                                          ? 'orang_lain'
                                          : 'diri_sendiri',

                                           'nama_penerima':
                                           _kirimKeOrangLain
                                           ? _namaPenerimaController
                                           .text
                                           .trim()
                                           : _namaPenerimaSendiriController
                                            .text
                                           .trim(),

                                           'no_hp_penerima':
                                           _kirimKeOrangLain
                                           ? _noHpPenerimaController
                                           .text
                                           .trim()
                                           : _noHpPenerimaSendiriController
                                           .text
                                           .trim(),

                                           'alamat_lengkap_manual':
                                            alamatLengkapPengiriman,

                                      });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "User belum login, silakan login kembali.",
                                      ),
                                    ),
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
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Pesanan Berhasil!",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _selectedMethodIndex == 0
                                                ? "Bukti pembayaran asli telah terkirim ke server database Admin. Pesanan Anda segera diproses!"
                                                : "Pesanan COD berhasil dibuat ke sistem database.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFD31124,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                ); // tutup dialog sukses

                                                Navigator.pop(context, true);
                                              },
                                              child: Text(
                                                "Kembali ke Beranda",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                ),
                                              ),
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
                                    content: Text(
                                      "Gagal mengirim ke database server: $e",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
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
        ],
      ),
      ),
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
          "Rp ${_formatRupiah(amount)}",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedMethodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
  setState(() {
    _metodeDiubahManual = true;
    _selectedMethodIndex = index;
  });
},
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
    const String nomorRekening = "009401056589506";
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
                    "BRI",
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
                      "Bank Rakyat Indonesia (BRI)",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "a.n PT Lapar Manten Group",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nomor Rekening",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    nomorRekening,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: nomorRekening));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nomor rekening disalin!")),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Unggah Bukti Transfer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSelectionDialog,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Klik di sini untuk upload foto",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Format: JPG, PNG (Maks. 2MB)",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 10,
                        ),
                      ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                "Informasi COD",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Pembayaran dilakukan secara tunai kepada kurir saat pesanan sampai di lokasi Anda. Pastikan menyiapkan uang pas sesuai dengan 'Total Bayar' di atas.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}