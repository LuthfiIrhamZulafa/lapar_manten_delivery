import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pilih_lokasi_page.dart';

class OjekPage extends StatefulWidget {
  const OjekPage({super.key});

  @override
  State<OjekPage> createState() => _OjekPageState();
}

class _OjekPageState extends State<OjekPage> {
  static const Color _primaryRed = Color(0xFFD31124);
  static const Color _darkRed = Color(0xFFB80018);
  static const LatLng _sumedangCenter = LatLng(-6.8632, 107.9254);
  static const int _baseFare = 11000;
  static const int _outsideCityFarePerKm = 2000;

  final MapController _mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();

  // Batas wilayah Sumedang Kota disamakan dengan PaymentPage.
  final List<LatLng> _sumedangCityBoundary = const [
    LatLng(-6.826628, 107.918180), // Jembatan Bojong
    LatLng(-6.826399, 107.922639), // Perempatan Jatihurip
    LatLng(-6.834942, 107.930769), // Bundaran Alamsari
    LatLng(-6.840782, 107.934744), // Jembatan Dano
    LatLng(-6.849795, 107.932911), // Jembatan Tegalkalong
    LatLng(-6.855750, 107.931398), // Talun
    LatLng(-6.859139, 107.924645), // Jembatan Cipameungpeuk
    LatLng(-6.860450, 107.916264), // Binokasih
    LatLng(-6.849605, 107.912057), // Kutamaya
  ];

  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String _pickupAddress = 'Mencari lokasi perangkat...';
  String _destinationAddress = '';
  String _paymentMethod = 'COD';
  File? _paymentProof;
  bool _isLoadingPickup = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoadingPickup = false;
          _pickupAddress = 'GPS belum diaktifkan';
        });
        _showMessage(
          'Aktifkan GPS untuk menggunakan lokasi jemput saat ini.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoadingPickup = false;
          _pickupAddress = 'Izin lokasi belum diberikan';
        });
        _showMessage(
          'Berikan izin lokasi atau pilih titik jemput melalui peta.',
        );
        return;
      }

      final Position position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _pickupLocation = currentLocation;
        _pickupAddress = 'Lokasi Saya';
        _isLoadingPickup = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(currentLocation, 15);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingPickup = false;
        _pickupAddress = 'Lokasi belum tersedia';
      });
      _showMessage('Lokasi perangkat gagal diambil: $error');
    }
  }

  Future<void> _selectLocation({
    required bool isPickup,
  }) async {
    final LatLng? initialLocation =
        isPickup ? _pickupLocation : _destinationLocation;

    final Map<String, dynamic>? result =
        await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (BuildContext context) => AmbilLokasiPage(
          initialLat: initialLocation?.latitude,
          initialLng: initialLocation?.longitude,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final double? latitude =
        (result['latitude'] as num?)?.toDouble();
    final double? longitude =
        (result['longitude'] as num?)?.toDouble();
    final String address =
        result['alamat_teks']?.toString().trim() ?? '';

    if (latitude == null || longitude == null) {
      _showMessage('Koordinat lokasi tidak valid.');
      return;
    }

    final LatLng selectedLocation = LatLng(
      latitude,
      longitude,
    );

    setState(() {
      if (isPickup) {
        _pickupLocation = selectedLocation;
        _pickupAddress = address.isEmpty
            ? 'Lokasi jemput dipilih'
            : address;
        _isLoadingPickup = false;
      } else {
        _destinationLocation = selectedLocation;
        _destinationAddress = address.isEmpty
            ? 'Lokasi tujuan dipilih'
            : address;
      }
    });

    _moveMapToShowRoute();
  }

  void _moveMapToShowRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_pickupLocation != null &&
          _destinationLocation != null) {
        final LatLng center = LatLng(
          (_pickupLocation!.latitude +
                  _destinationLocation!.latitude) /
              2,
          (_pickupLocation!.longitude +
                  _destinationLocation!.longitude) /
              2,
        );
        _mapController.move(center, 13);
      } else {
        final LatLng? location =
            _destinationLocation ?? _pickupLocation;
        if (location != null) {
          _mapController.move(location, 15);
        }
      }
    });
  }

  double? get _distanceKm {
    if (_pickupLocation == null ||
        _destinationLocation == null) {
      return null;
    }

    return const Distance().as(
      LengthUnit.Kilometer,
      _pickupLocation!,
      _destinationLocation!,
    );
  }

  int? get _estimatedMinutes {
    final double? distance = _distanceKm;
    if (distance == null) return null;

    const double averageSpeed = 25;
    final int minutes =
        ((distance / averageSpeed) * 60).ceil();

    return minutes < 5 ? 5 : minutes;
  }

  bool get _destinationInsideCity {
    final LatLng? destination = _destinationLocation;
    if (destination == null) return true;

    return _isInsideSumedangCity(
      destination,
      _sumedangCityBoundary,
    );
  }

  double get _outsideCityDistanceKm {
    final LatLng? destination = _destinationLocation;

    if (destination == null || _destinationInsideCity) {
      return 0;
    }

    return _distanceFromNearestBoundary(
      destination,
      _sumedangCityBoundary,
    );
  }

  int get _fare {
    if (_destinationLocation == null || _destinationInsideCity) {
      return _baseFare;
    }

    final int chargedKilometers =
        _outsideCityDistanceKm.ceil();

    return _baseFare +
        (chargedKilometers * _outsideCityFarePerKm);
  }

  String get _fareDescription {
    if (_destinationLocation == null) {
      return 'Tarif dasar dalam Kota Sumedang';
    }

    if (_destinationInsideCity) {
      return 'Tujuan berada di dalam Kota Sumedang';
    }

    final int chargedKilometers =
        _outsideCityDistanceKm.ceil();

    return 'Luar kota: $chargedKilometers km × '
        '${_formatRupiah(_outsideCityFarePerKm)}';
  }

  String _formatRupiah(int amount) {
    final String value = amount.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      if (index > 0 &&
          (value.length - index) % 3 == 0) {
        result.write('.');
      }
      result.write(value[index]);
    }

    return 'Rp$result';
  }

  bool _isInsideSumedangCity(
    LatLng point,
    List<LatLng> polygon,
  ) {
    int previousIndex = polygon.length - 1;
    bool inside = false;
    final double x = point.longitude;
    final double y = point.latitude;

    for (int index = 0;
        index < polygon.length;
        index++) {
      final bool crossesLatitude =
          (polygon[index].latitude < y &&
                  polygon[previousIndex].latitude >= y) ||
              (polygon[previousIndex].latitude < y &&
                  polygon[index].latitude >= y);

      if (crossesLatitude &&
          (polygon[index].longitude <= x ||
              polygon[previousIndex].longitude <= x)) {
        final double intersectionLongitude =
            polygon[index].longitude +
                (y - polygon[index].latitude) /
                    (polygon[previousIndex].latitude -
                        polygon[index].latitude) *
                    (polygon[previousIndex].longitude -
                        polygon[index].longitude);

        if (intersectionLongitude < x) {
          inside = !inside;
        }
      }

      previousIndex = index;
    }

    return inside;
  }

  double _distanceBetween(
    LatLng first,
    LatLng second,
  ) {
    const double earthRadiusKm = 6371;
    const double degreesToRadians =
        math.pi / 180;

    final double latitudeDifference =
        (second.latitude - first.latitude) *
            degreesToRadians;
    final double longitudeDifference =
        (second.longitude - first.longitude) *
            degreesToRadians;

    final double haversine =
        math.sin(latitudeDifference / 2) *
                math.sin(latitudeDifference / 2) +
            math.cos(first.latitude * degreesToRadians) *
                math.cos(second.latitude *
                    degreesToRadians) *
                math.sin(longitudeDifference / 2) *
                math.sin(longitudeDifference / 2);

    final double angularDistance = 2 *
        math.atan2(
          math.sqrt(haversine),
          math.sqrt(1 - haversine),
        );

    return earthRadiusKm * angularDistance;
  }

  double _distanceFromNearestBoundary(
    LatLng location,
    List<LatLng> polygon,
  ) {
    double minimumDistance = double.infinity;

    for (int index = 0;
        index < polygon.length;
        index++) {
      final LatLng firstPoint = polygon[index];
      final LatLng secondPoint =
          polygon[(index + 1) % polygon.length];

      final double distance = _distanceToBoundaryLine(
        location,
        firstPoint,
        secondPoint,
      );

      if (distance < minimumDistance) {
        minimumDistance = distance;
      }
    }

    return minimumDistance;
  }

  double _distanceToBoundaryLine(
    LatLng point,
    LatLng lineStart,
    LatLng lineEnd,
  ) {
    final double x = point.longitude;
    final double y = point.latitude;
    final double startX = lineStart.longitude;
    final double startY = lineStart.latitude;
    final double endX = lineEnd.longitude;
    final double endY = lineEnd.latitude;
    final double deltaX = endX - startX;
    final double deltaY = endY - startY;

    if (deltaX == 0 && deltaY == 0) {
      return _distanceBetween(point, lineStart);
    }

    final double projection =
        ((x - startX) * deltaX +
                (y - startY) * deltaY) /
            (deltaX * deltaX + deltaY * deltaY);

    if (projection < 0) {
      return _distanceBetween(point, lineStart);
    }

    if (projection > 1) {
      return _distanceBetween(point, lineEnd);
    }

    final LatLng projectedPoint = LatLng(
      startY + projection * deltaY,
      startX + projection * deltaX,
    );

    return _distanceBetween(point, projectedPoint);
  }

  Future<void> _changePaymentMethod() async {
    final String? selectedMethod =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pilih Metode Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _paymentOption(
                  context: context,
                  icon: Icons.payments_outlined,
                  title: 'Bayar di Tempat (COD)',
                  value: 'COD',
                ),
                _paymentOption(
                  context: context,
                  icon: Icons.account_balance_outlined,
                  title: 'Transfer Bank',
                  value: 'Transfer Bank',
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedMethod == null) return;

    setState(() {
      _paymentMethod = selectedMethod;
      if (selectedMethod == 'COD') {
        _paymentProof = null;
      }
    });
  }

  Future<void> _pickPaymentProof() async {
    try {
      final XFile? selectedImage =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (!mounted || selectedImage == null) return;

      setState(() {
        _paymentProof = File(selectedImage.path);
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Bukti pembayaran gagal dipilih: $error',
      );
    }
  }

  Widget _paymentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final bool selected = _paymentMethod == value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? _primaryRed.withValues(alpha: 0.10)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: selected ? _primaryRed : Colors.grey.shade700,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: selected ? _primaryRed : Colors.grey,
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    if (_pickupLocation == null) {
      _showMessage('Tentukan lokasi jemput terlebih dahulu.');
      return;
    }

    if (_destinationLocation == null) {
      _showMessage('Tentukan lokasi tujuan terlebih dahulu.');
      return;
    }

    if (_paymentMethod == 'Transfer Bank' &&
        _paymentProof == null) {
      _showMessage(
        'Unggah bukti transfer terlebih dahulu.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ringkasan Pesanan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Layanan', 'Ojek Motor'),
              _summaryRow(
                'Jarak',
                '${_distanceKm!.toStringAsFixed(1)} km',
              ),
              _summaryRow(
                'Estimasi',
                '$_estimatedMinutes menit',
              ),
              _summaryRow(
                'Ongkos',
                _formatRupiah(_fare),
              ),
              _summaryRow('Pembayaran', _paymentMethod),
              const SizedBox(height: 12),
              Text(
                _fareDescription,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kembali'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryRed,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _saveOrderToSupabase();
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveOrderToSupabase() async {
    final SupabaseClient supabase =
        Supabase.instance.client;
    final User? user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
      return;
    }

    final LatLng? pickup = _pickupLocation;
    final LatLng? destination = _destinationLocation;

    if (pickup == null || destination == null) {
      _showMessage('Data lokasi belum lengkap.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String orderId =
          'LM-${DateTime.now().millisecondsSinceEpoch}';
      String paymentProofUrl = '';

      if (_paymentMethod == 'Transfer Bank') {
        final File? proofFile = _paymentProof;

        if (proofFile == null) {
          throw Exception(
            'Bukti transfer belum dipilih.',
          );
        }

        final String extension =
            proofFile.path.contains('.')
                ? proofFile.path.split('.').last
                : 'jpg';
        final String filePath =
            'public/${user.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';

        await supabase.storage
            .from('bukti_transfer')
            .upload(
              filePath,
              proofFile,
              fileOptions: const FileOptions(
                upsert: false,
              ),
            );

        paymentProofUrl = supabase.storage
            .from('bukti_transfer')
            .getPublicUrl(filePath);
      }

      final Map<String, dynamic>? profile =
          await supabase
              .from('users')
              .select('nama_lengkap, nomor_hp')
              .eq('id', user.id)
              .maybeSingle();

      final String customerName =
          profile?['nama_lengkap']?.toString().trim() ??
              user.userMetadata?['full_name']
                  ?.toString()
                  .trim() ??
              user.email?.split('@').first ??
              'Pelanggan';
      final String customerPhone =
          profile?['nomor_hp']?.toString().trim() ?? '';
      final double distance =
          _distanceKm ?? 0;

      await supabase.from('pemesanan').insert({
        'order_id': orderId,
        'user_id': user.id,
        'gambar_menu': '',
        'nama_menu': 'Ojek Motor',
        'jumlah': 1,
        'total_harga': _fare,
        'status': _paymentMethod == 'Transfer Bank'
            ? 'Menunggu Verifikasi'
            : 'Pending',
        'bukti_transfer': paymentProofUrl,
        'detail_pesanan':
            'Layanan Ojek Motor. '
            'Jarak ${distance.toStringAsFixed(2)} km. '
            'Jemput: $_pickupAddress. '
            'Tujuan: $_destinationAddress.',
        'catatan': 'Lokasi jemput: $_pickupAddress',
        'metode_pembayaran': _paymentMethod,
        'latitude_tujuan': destination.latitude,
        'longitude_tujuan': destination.longitude,
        'tipe_pengiriman': 'ojek',
        'nama_penerima': customerName,
        'no_hp_penerima': customerPhone,
        'alamat_lengkap_manual': _destinationAddress,
        'jenis_layanan': 'ojek',
        'alamat_jemput': _pickupAddress,
        'latitude_jemput': pickup.latitude,
        'longitude_jemput': pickup.longitude,
        'jarak_km': double.parse(
          distance.toStringAsFixed(2),
        ),
      });

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      await _showOrderSuccessDialog(orderId);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Pesanan gagal disimpan: $error',
      );
    }
  }

  Future<void> _showOrderSuccessDialog(
    String orderId,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 14),
              Text(
                'Pesanan Ojek Berhasil',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nomor pesanan: $orderId\n'
                'Pesanan sudah dikirim ke dashboard admin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryRed,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, true);
                },
                child: const Text('Selesai'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _darkRed,
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cara Memesan'),
          content: const Text(
            '1. Pastikan lokasi jemput sudah benar.\n'
            '2. Pilih lokasi tujuan melalui peta.\n'
            '3. Pilih metode pembayaran.\n'
            '4. Tekan Pesan Sekarang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter =
        _pickupLocation ?? _sumedangCenter;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: _primaryRed,
          ),
        ),
        title: Text(
          'Lapar Manten Ojek',
          style: GoogleFonts.poppins(
            color: _darkRed,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showHelp,
            icon: const Icon(
              Icons.help_outline,
              color: _darkRed,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 470,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: mapCenter,
                          initialZoom: 14,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.lapar_manten_delivery',
                          ),
                          if (_pickupLocation != null &&
                              _destinationLocation != null)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [
                                    _pickupLocation!,
                                    _destinationLocation!,
                                  ],
                                  strokeWidth: 4,
                                  color: _primaryRed,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (_pickupLocation != null)
                                Marker(
                                  point: _pickupLocation!,
                                  width: 48,
                                  height: 48,
                                  child: const _MapMarker(
                                    icon: Icons.my_location,
                                    color: _primaryRed,
                                  ),
                                ),
                              if (_destinationLocation != null)
                                Marker(
                                  point: _destinationLocation!,
                                  width: 48,
                                  height: 48,
                                  child: const _MapMarker(
                                    icon: Icons.location_on,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 22,
                        child: _buildLocationCard(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    0,
                  ),
                  child: Text(
                    'Layanan Ojek',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _buildServiceCard(
                    icon: Icons.moped,
                    title: 'Ojek Motor',
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _buildFareCard(),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _buildPaymentCard(),
                ),
                if (_paymentMethod == 'Transfer Bank') ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _buildPaymentProofCard(),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.paddingOf(context).bottom + 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pesan Sekarang • ${_formatRupiah(_fare)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _primaryRed.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            isPickup: true,
            icon: _isLoadingPickup
                ? Icons.location_searching
                : Icons.circle,
            label: 'Lokasi Jemput',
            address: _pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Divider(
              height: 20,
              color: Colors.grey.shade200,
            ),
          ),
          _buildLocationRow(
            isPickup: false,
            icon: Icons.location_on_outlined,
            label: 'Tujuan',
            address: _destinationAddress.isEmpty
                ? 'Mau pergi ke mana?'
                : _destinationAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required bool isPickup,
    required IconData icon,
    required String label,
    required String address,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _selectLocation(isPickup: isPickup),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Icon(
                icon,
                size: isPickup ? 16 : 27,
                color: isPickup
                    ? _primaryRed
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: address == 'Mau pergi ke mana?'
                          ? Colors.grey.shade400
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  color: _primaryRed,
                  size: 21,
                ),
                const SizedBox(width: 4),
                Text(
                  'Peta',
                  style: GoogleFonts.poppins(
                    color: _darkRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
  }) {
    final int? estimatedMinutes = _estimatedMinutes;

    return Material(
      color: _primaryRed,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: null,
        child: Container(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _darkRed,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      estimatedMinutes == null
                          ? 'Pilih tujuan untuk melihat estimasi'
                          : 'Estimasi ± $estimatedMinutes menit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(
                          alpha: 0.88,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatRupiah(_fare),
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _primaryRed.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _primaryRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: _primaryRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongkos Perjalanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatRupiah(_fare),
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: _darkRed,
                  ),
                ),
                Text(
                  _fareDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofCard() {
    final bool proofSelected = _paymentProof != null;

    return Material(
      color: proofSelected
          ? Colors.green.shade50
          : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _pickPaymentProof,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: proofSelected
                  ? Colors.green
                  : _primaryRed.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                proofSelected
                    ? Icons.check_circle
                    : Icons.upload_file,
                color: proofSelected
                    ? Colors.green
                    : _primaryRed,
                size: 34,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      proofSelected
                          ? 'Bukti transfer sudah dipilih'
                          : 'Unggah bukti transfer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      proofSelected
                          ? 'Tekan untuk mengganti gambar'
                          : 'Wajib sebelum pesanan dikirim',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    final bool isCod = _paymentMethod == 'COD';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _changePaymentMethod,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _primaryRed.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primaryRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCod
                      ? Icons.payments_outlined
                      : Icons.account_balance_outlined,
                  color: _primaryRed,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      isCod
                          ? 'Bayar di Tempat (COD)'
                          : 'Transfer Bank',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Ubah',
                style: GoogleFonts.poppins(
                  color: _darkRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MapMarker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 29,
      ),
    );
  }
}
