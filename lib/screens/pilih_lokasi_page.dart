import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AmbilLokasiPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const AmbilLokasiPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AmbilLokasiPage> createState() => _AmbilLokasiPageState();
}

class _AmbilLokasiPageState extends State<AmbilLokasiPage> {
  LatLng _lokasiTerpilih = const LatLng(-6.8632, 107.9254); // Default Sumedang Kota jika GPS mati
  final MapController _mapController = MapController();
  bool _isLoading = true;

  Future<String> _getAddressFromLatLng(
    double lat,
    double lng,
) async {
  try {
    final response = await http.get(
      Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng",
      ),
      headers: {
        "User-Agent": "LaparMantenApp/1.0",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["display_name"] ?? "";
    }

    return "";
  } catch (e) {
    return "";
  }
}

 @override
void initState() {
  super.initState();

  if (widget.initialLat != null &&
      widget.initialLng != null) {

    _lokasiTerpilih = LatLng(
      widget.initialLat!,
      widget.initialLng!,
    );

    _isLoading = false;
  } else {
    _tentukanPosisiAwalHP();
  }
}
  // Fungsi mengunci posisi GPS HP di awal halaman dibuka
  Future<void> _tentukanPosisiAwalHP() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar('GPS HP kamu mati. Silakan aktifkan terlebih dahulu.');
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('Aplikasi butuh izin lokasi untuk maps.');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar('Izin lokasi ditolak permanen, atur di setelan HP.');
      setState(() => _isLoading = false);
      return;
    }

    // Ambil posisi sekarang
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
  _lokasiTerpilih = LatLng(position.latitude, position.longitude);
  _isLoading = false;
});

WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  _mapController.move(_lokasiTerpilih, 16.0);
});
  }

  void _showErrorSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Geser Pin Lokasi Rumah",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD31124)))
          : Stack(
              children: [
                // 1. WIDGET VISUALISASI PETA MAPS
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _lokasiTerpilih,
                    initialZoom: 16.0,
                    maxZoom: 18.0,
                    minZoom: 10.0,
                    // EVENT KETIKA PETANYA DIGESER-GESER OLEH USER
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        setState(() {
                          // Otomatis mengunci titik koordinat tepat di TENGAH-TENGAH layar (Crosshair)
                          _lokasiTerpilih = camera.center;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.laparmanten.app',
                    ),
                  ],
                ),

                // 2. PIN LOGO RUMAH DI TENGAH LAYAR (DILUAR LAYER MAPS AGAR SEPERTI GOJEK/GRAB)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35), // Mengimbangi ekor pin
                    child: Icon(
                      Icons.location_on,
                      size: 45,
                      color: const Color(0xFFD31124), // Merah Lapar Manten
                    ),
                  ),
                ),

                // 3. DETAIL KOORDINAT & TOMBOL KONFIRMASI ALAMAT
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Koordinat: ${_lokasiTerpilih.latitude.toStringAsFixed(6)}, ${_lokasiTerpilih.longitude.toStringAsFixed(6)}",
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD31124),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
  String alamat = await _getAddressFromLatLng(
    _lokasiTerpilih.latitude,
    _lokasiTerpilih.longitude,
  );

  Navigator.pop(context, {
    'latitude': _lokasiTerpilih.latitude,
    'longitude': _lokasiTerpilih.longitude,
    'alamat_teks': alamat,
  });
},

                              child: Text(
                                "Gunakan Lokasi Ini",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}