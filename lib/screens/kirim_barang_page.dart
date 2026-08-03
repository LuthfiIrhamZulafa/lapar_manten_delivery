import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pilih_lokasi_page.dart';

class KirimBarangPage extends StatefulWidget {
  const KirimBarangPage({super.key});

  @override
  State<KirimBarangPage> createState() => _KirimBarangPageState();
}

class _KirimBarangPageState extends State<KirimBarangPage> {
  static const Color _primaryRed = Color(0xFFD31124);
  static const Color _darkRed = Color(0xFFB80018);
  static const int _baseFare = 11000;
  static const int _outsideCityFarePerKm = 2000;
  static const String _bankCode = 'BCA';
  static const String _bankName = 'Bank Central Asia (BCA)';
  static const String _accountNumber = '442801015794509';
  static const String _accountHolder = 'PT Lapar Manten Group';

  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _pickupAddressDetailController =
      TextEditingController();
  final TextEditingController _destinationAddressDetailController =
      TextEditingController();
  final TextEditingController _packageNoteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<LatLng> _sumedangCityBoundary = const [
    LatLng(-6.826628, 107.918180),
    LatLng(-6.826399, 107.922639),
    LatLng(-6.834942, 107.930769),
    LatLng(-6.840782, 107.934744),
    LatLng(-6.849795, 107.932911),
    LatLng(-6.855750, 107.931398),
    LatLng(-6.859139, 107.924645),
    LatLng(-6.860450, 107.916264),
    LatLng(-6.849605, 107.912057),
  ];

  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String _pickupAddress = '';
  String _destinationAddress = '';
  String _selectedPackageType = 'Dokumen';
  String _paymentMethod = 'COD';
  File? _paymentProof;
  bool _isLoadingProfile = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _pickupAddressDetailController.dispose();
    _destinationAddressDetailController.dispose();
    _packageNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCustomerProfile(), _loadCurrentPickupLocation()]);

    if (!mounted) return;

    setState(() {
      _isLoadingProfile = false;
    });
  }

  Future<void> _loadCustomerProfile() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final User? user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final Map<String, dynamic>? profile = await supabase
          .from('users')
          .select('nama_lengkap, nomor_hp')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      _senderNameController.text =
          profile?['nama_lengkap']?.toString().trim() ??
          user.userMetadata?['full_name']?.toString().trim() ??
          user.email?.split('@').first ??
          '';
      _senderPhoneController.text =
          profile?['nomor_hp']?.toString().trim() ?? user.phone ?? '';
    } catch (error) {
      debugPrint('Profil pengirim gagal diambil: $error');
    }
  }

  Future<void> _loadCurrentPickupLocation() async {
    try {
      final bool locationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!locationServiceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _pickupAddress = 'Lokasi perangkat saat ini';
      });
    } catch (error) {
      debugPrint('Lokasi awal pengirim gagal diambil: $error');
    }
  }

  Future<void> _selectLocation({required bool isPickup}) async {
    final LatLng? initialLocation = isPickup
        ? _pickupLocation
        : _destinationLocation;

    final Map<String, dynamic>? result = await Navigator.of(context)
        .push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (BuildContext context) => AmbilLokasiPage(
              initialLat: initialLocation?.latitude,
              initialLng: initialLocation?.longitude,
            ),
          ),
        );

    if (!mounted || result == null) return;

    final double? latitude = (result['latitude'] as num?)?.toDouble();
    final double? longitude = (result['longitude'] as num?)?.toDouble();
    final String address = result['alamat_teks']?.toString().trim() ?? '';

    if (latitude == null || longitude == null) {
      _showMessage('Koordinat lokasi tidak valid.');
      return;
    }

    setState(() {
      if (isPickup) {
        _pickupLocation = LatLng(latitude, longitude);
        _pickupAddress = address.isEmpty
            ? 'Lokasi penjemputan dipilih'
            : address;
      } else {
        _destinationLocation = LatLng(latitude, longitude);
        _destinationAddress = address.isEmpty
            ? 'Lokasi tujuan dipilih'
            : address;
      }
    });
  }

  double? get _distanceKm {
    if (_pickupLocation == null || _destinationLocation == null) {
      return null;
    }

    return const Distance().as(
      LengthUnit.Kilometer,
      _pickupLocation!,
      _destinationLocation!,
    );
  }

  bool get _destinationInsideCity {
    final LatLng? destination = _destinationLocation;

    if (destination == null) return true;

    return _isInsideSumedangCity(destination, _sumedangCityBoundary);
  }

  double get _outsideCityDistanceKm {
    final LatLng? destination = _destinationLocation;

    if (destination == null || _destinationInsideCity) {
      return 0;
    }

    return _distanceFromNearestBoundary(destination, _sumedangCityBoundary);
  }

  int get _fare {
    if (_destinationLocation == null || _destinationInsideCity) {
      return _baseFare;
    }

    final int chargedKilometers = _outsideCityDistanceKm.ceil();

    return _baseFare + chargedKilometers * _outsideCityFarePerKm;
  }

  String get _fareDescription {
    if (_destinationLocation == null) {
      return 'Tarif dasar dalam Kota Sumedang';
    }

    if (_destinationInsideCity) {
      return 'Tujuan berada di dalam Kota Sumedang';
    }

    final int chargedKilometers = _outsideCityDistanceKm.ceil();

    return 'Luar kota: $chargedKilometers km × '
        '${_formatRupiah(_outsideCityFarePerKm)}';
  }

  String _formatRupiah(int amount) {
    final String value = amount.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      if (index > 0 && (value.length - index) % 3 == 0) {
        result.write('.');
      }

      result.write(value[index]);
    }

    return 'Rp$result';
  }

  bool _isInsideSumedangCity(LatLng point, List<LatLng> polygon) {
    int previousIndex = polygon.length - 1;
    bool inside = false;
    final double x = point.longitude;
    final double y = point.latitude;

    for (int index = 0; index < polygon.length; index++) {
      final bool crossesLatitude =
          (polygon[index].latitude < y &&
              polygon[previousIndex].latitude >= y) ||
          (polygon[previousIndex].latitude < y && polygon[index].latitude >= y);

      if (crossesLatitude &&
          (polygon[index].longitude <= x ||
              polygon[previousIndex].longitude <= x)) {
        final double intersectionLongitude =
            polygon[index].longitude +
            (y - polygon[index].latitude) /
                (polygon[previousIndex].latitude - polygon[index].latitude) *
                (polygon[previousIndex].longitude - polygon[index].longitude);

        if (intersectionLongitude < x) {
          inside = !inside;
        }
      }

      previousIndex = index;
    }

    return inside;
  }

  double _distanceBetween(LatLng first, LatLng second) {
    const double earthRadiusKm = 6371;
    const double degreesToRadians = math.pi / 180;

    final double latitudeDifference =
        (second.latitude - first.latitude) * degreesToRadians;
    final double longitudeDifference =
        (second.longitude - first.longitude) * degreesToRadians;

    final double haversine =
        math.sin(latitudeDifference / 2) * math.sin(latitudeDifference / 2) +
        math.cos(first.latitude * degreesToRadians) *
            math.cos(second.latitude * degreesToRadians) *
            math.sin(longitudeDifference / 2) *
            math.sin(longitudeDifference / 2);

    final double angularDistance =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return earthRadiusKm * angularDistance;
  }

  double _distanceFromNearestBoundary(LatLng location, List<LatLng> polygon) {
    double minimumDistance = double.infinity;

    for (int index = 0; index < polygon.length; index++) {
      final LatLng lineStart = polygon[index];
      final LatLng lineEnd = polygon[(index + 1) % polygon.length];
      final double distance = _distanceToBoundaryLine(
        location,
        lineStart,
        lineEnd,
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
        ((x - startX) * deltaX + (y - startY) * deltaY) /
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

  bool _validPhoneNumber(String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    return digits.length >= 9 && digits.length <= 15;
  }

  Future<void> _changePaymentMethod() async {
    final String? selectedMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

  Widget _paymentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final bool selected = _paymentMethod == value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: selected ? _primaryRed : Colors.grey),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? _primaryRed : Colors.grey,
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<void> _pickPaymentProof() async {
    try {
      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (!mounted || selectedImage == null) return;

      setState(() {
        _paymentProof = File(selectedImage.path);
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Bukti pembayaran gagal dipilih: $error');
    }
  }

  Future<void> _showOrderSummary() async {
    if (_isSubmitting) return;

    final String senderName = _senderNameController.text.trim();
    final String senderPhone = _senderPhoneController.text.trim();
    final String receiverName = _receiverNameController.text.trim();
    final String receiverPhone = _receiverPhoneController.text.trim();
    final String pickupAddressDetail = _pickupAddressDetailController.text
        .trim();
    final String destinationAddressDetail = _destinationAddressDetailController
        .text
        .trim();

    if (senderName.isEmpty ||
        senderPhone.isEmpty ||
        receiverName.isEmpty ||
        receiverPhone.isEmpty) {
      _showMessage('Lengkapi nama dan nomor telepon pengirim serta penerima.');
      return;
    }

    if (!_validPhoneNumber(senderPhone) || !_validPhoneNumber(receiverPhone)) {
      _showMessage('Nomor telepon harus terdiri dari 9–15 angka.');
      return;
    }

    if (_pickupLocation == null) {
      _showMessage('Tentukan lokasi penjemputan terlebih dahulu.');
      return;
    }

    if (_destinationLocation == null) {
      _showMessage('Tentukan lokasi tujuan terlebih dahulu.');
      return;
    }

    if (pickupAddressDetail.isEmpty || destinationAddressDetail.isEmpty) {
      _showMessage(
        'Lengkapi detail alamat atau patokan penjemputan dan tujuan.',
      );
      return;
    }

    if (_paymentMethod == 'Transfer Bank' && _paymentProof == null) {
      _showMessage('Unggah bukti transfer terlebih dahulu.');
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
            'Ringkasan Pengiriman',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow('Pengirim', senderName),
                _summaryRow('Penerima', receiverName),
                _summaryRow(
                  'Jemput',
                  '$_pickupAddress\n'
                      'Patokan: $pickupAddressDetail',
                ),
                _summaryRow(
                  'Tujuan',
                  '$_destinationAddress\n'
                      'Patokan: $destinationAddressDetail',
                ),
                _summaryRow('Paket', _selectedPackageType),
                _summaryRow(
                  'Jarak',
                  '${(_distanceKm ?? 0).toStringAsFixed(2)} km',
                ),
                _summaryRow('Ongkos', _formatRupiah(_fare)),
                _summaryRow('Pembayaran', _paymentMethod),
                const SizedBox(height: 8),
                Text(
                  _fareDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kembali'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _primaryRed),
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOrderToSupabase() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final User? user = supabase.auth.currentUser;
    final LatLng? pickup = _pickupLocation;
    final LatLng? destination = _destinationLocation;

    if (user == null) {
      _showMessage('Sesi login tidak ditemukan. Silakan login kembali.');
      return;
    }

    if (pickup == null || destination == null) {
      _showMessage('Data lokasi belum lengkap.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String orderId = 'LM-${DateTime.now().millisecondsSinceEpoch}';
      String paymentProofUrl = '';

      if (_paymentMethod == 'Transfer Bank') {
        final File? proofFile = _paymentProof;

        if (proofFile == null) {
          throw Exception('Bukti transfer belum dipilih.');
        }

        final String extension = proofFile.path.contains('.')
            ? proofFile.path.split('.').last
            : 'jpg';
        final String filePath =
            'public/${user.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';

        await supabase.storage
            .from('bukti_transfer')
            .upload(
              filePath,
              proofFile,
              fileOptions: const FileOptions(upsert: false),
            );

        paymentProofUrl = supabase.storage
            .from('bukti_transfer')
            .getPublicUrl(filePath);
      }

      final double distance = _distanceKm ?? 0;
      final String packageNote = _packageNoteController.text.trim();
      final String pickupAddressDetail = _pickupAddressDetailController.text
          .trim();
      final String destinationAddressDetail =
          _destinationAddressDetailController.text.trim();
      final String completePickupAddress =
          '$_pickupAddress. '
          'Detail/Patokan: $pickupAddressDetail';
      final String completeDestinationAddress =
          '$_destinationAddress. '
          'Detail/Patokan: $destinationAddressDetail';

      await supabase.from('pemesanan').insert({
        'order_id': orderId,
        'user_id': user.id,
        'gambar_menu': '',
        'nama_menu': 'Kirim Barang - $_selectedPackageType',
        'jumlah': 1,
        'total_harga': _fare,
        'status': _paymentMethod == 'Transfer Bank'
            ? 'Menunggu Verifikasi'
            : 'Pending',
        'bukti_transfer': paymentProofUrl,
        'detail_pesanan':
            'Jenis paket: $_selectedPackageType. '
            '${packageNote.isEmpty ? '' : 'Keterangan: $packageNote'}',
        'catatan': packageNote,
        'metode_pembayaran': _paymentMethod,
        'latitude_tujuan': destination.latitude,
        'longitude_tujuan': destination.longitude,
        'tipe_pengiriman': 'kirim_barang',
        'nama_penerima': _receiverNameController.text.trim(),
        'no_hp_penerima': _receiverPhoneController.text.trim(),
        'alamat_lengkap_manual': completeDestinationAddress,
        'jenis_layanan': 'kirim_barang',
        'alamat_jemput': completePickupAddress,
        'latitude_jemput': pickup.latitude,
        'longitude_jemput': pickup.longitude,
        'jarak_km': double.parse(distance.toStringAsFixed(2)),
        'nama_pengirim': _senderNameController.text.trim(),
        'no_hp_pengirim': _senderPhoneController.text.trim(),
        'jenis_paket': _selectedPackageType,
        'detail_alamat_jemput': pickupAddressDetail,
        'detail_alamat_tujuan': destinationAddressDetail,
      });

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      await _showSuccessDialog(orderId);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage('Pesanan gagal disimpan: $error');
    }
  }

  Future<void> _showSuccessDialog(String orderId) async {
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
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 14),
              Text(
                'Pengiriman Berhasil Dibuat',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
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
                style: FilledButton.styleFrom(backgroundColor: _primaryRed),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: _darkRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Lapar Manten Express',
          style: GoogleFonts.poppins(
            color: _darkRed,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showMessage('Lengkapi data pengirim, penerima, dan paket.');
            },
            icon: const Icon(Icons.help_outline, color: _darkRed),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator(color: _primaryRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonSection(
                    title: 'Detail Pengirim',
                    icon: Icons.outbox_outlined,
                    nameController: _senderNameController,
                    phoneController: _senderPhoneController,
                    locationLabel: 'Alamat Penjemputan',
                    locationHint: 'Pilih lokasi penjemputan',
                    address: _pickupAddress,
                    addressDetailController: _pickupAddressDetailController,
                    addressDetailLabel: 'Detail Alamat / Patokan Penjemputan',
                    addressDetailHint:
                        'Contoh: rumah pagar hitam, dekat masjid',
                    onSelectLocation: () => _selectLocation(isPickup: true),
                  ),
                  const SizedBox(height: 18),
                  _buildPersonSection(
                    title: 'Detail Penerima',
                    icon: Icons.move_to_inbox_outlined,
                    nameController: _receiverNameController,
                    phoneController: _receiverPhoneController,
                    locationLabel: 'Alamat Tujuan',
                    locationHint: 'Pilih lokasi tujuan',
                    address: _destinationAddress,
                    addressDetailController:
                        _destinationAddressDetailController,
                    addressDetailLabel: 'Detail Alamat / Patokan Tujuan',
                    addressDetailHint:
                        'Contoh: rumah warna hijau, gang sebelah minimarket',
                    onSelectLocation: () => _selectLocation(isPickup: false),
                  ),
                  const SizedBox(height: 28),
                  _buildPackageTypeSection(),
                  const SizedBox(height: 24),
                  _buildPackageNoteField(),
                  const SizedBox(height: 18),
                  _buildFareCard(),
                  const SizedBox(height: 14),
                  _buildPaymentCard(),
                  if (_paymentMethod == 'Transfer Bank') ...[
                    const SizedBox(height: 14),
                    _buildBankAccountCard(),
                    const SizedBox(height: 14),
                    _buildPaymentProofCard(),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _showOrderSummary,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pesan Sekarang • '
                          '${_formatRupiah(_fare)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonSection({
    required String title,
    required IconData icon,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required String locationLabel,
    required String locationHint,
    required String address,
    required TextEditingController addressDetailController,
    required String addressDetailLabel,
    required String addressDetailHint,
    required VoidCallback onSelectLocation,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryRed.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryRed, size: 27),
              const SizedBox(width: 9),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: title == 'Detail Pengirim'
                ? 'Nama Pengirim'
                : 'Nama Penerima',
            hint: 'Masukkan nama',
            controller: nameController,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            label: 'Nomor Telepon',
            hint: '08xxxxxxxxxx',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            locationLabel,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Material(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onSelectLocation,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        address.isEmpty ? locationHint : address,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: address.isEmpty
                              ? Colors.grey.shade500
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      color: _primaryRed,
                      size: 29,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            label: addressDetailLabel,
            hint: addressDetailHint,
            controller: addressDetailController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          minLines: maxLines > 1 ? 2 : 1,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primaryRed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageTypeSection() {
    const List<Map<String, dynamic>> packageTypes = [
      {'name': 'Dokumen', 'icon': Icons.description_outlined},
      {'name': 'Makanan', 'icon': Icons.restaurant_outlined},
      {'name': 'Elektronik', 'icon': Icons.devices_other_outlined},
      {'name': 'Lainnya', 'icon': Icons.inventory_2_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category_outlined, color: _primaryRed),
            const SizedBox(width: 9),
            Text(
              'Jenis Paket',
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packageTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> package = packageTypes[index];
            final String name = package['name'] as String;
            final IconData icon = package['icon'] as IconData;
            final bool selected = _selectedPackageType == name;

            return Material(
              color: selected
                  ? _primaryRed.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPackageType = name;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? _primaryRed
                          : _primaryRed.withValues(alpha: 0.14),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: selected ? _primaryRed : Colors.grey.shade700,
                        size: 34,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? _darkRed : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPackageNoteField() {
    return _buildTextField(
      label: 'Keterangan Paket (Opsional)',
      hint: 'Contoh: dokumen penting, makanan tidak boleh terbalik',
      controller: _packageNoteController,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryRed.withValues(alpha: 0.25)),
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
              Icons.local_shipping_outlined,
              color: _primaryRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongkos Pengiriman',
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
            border: Border.all(color: _primaryRed.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(
                isCod
                    ? Icons.payments_outlined
                    : Icons.account_balance_outlined,
                color: _primaryRed,
                size: 32,
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
                      isCod ? 'Bayar di Tempat (COD)' : 'Transfer Bank',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryRed.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekening Tujuan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF005E9F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _bankCode,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bankName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'a.n $_accountHolder',
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
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Rekening',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _accountNumber,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Salin nomor rekening',
                  icon: const Icon(Icons.copy, size: 21, color: _primaryRed),
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: _accountNumber),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor rekening berhasil disalin.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: _primaryRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transfer sesuai total pesanan, lalu unggah bukti pembayaran.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofCard() {
    final bool proofSelected = _paymentProof != null;

    return Material(
      color: proofSelected ? Colors.green.shade50 : Colors.white,
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
                proofSelected ? Icons.check_circle : Icons.upload_file,
                color: proofSelected ? Colors.green : _primaryRed,
                size: 34,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
}
