import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as lt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pilih_lokasi_page.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? alamat;

  const AddAddressPage({
    super.key,
    this.alamat,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  static const Color _merah = Color(0xFFC60D2A);

  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _namaTempatController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  String _labelAlamat = 'Rumah';
  String _alamatTeks = '';
  double? _latitude;
  double? _longitude;
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _sedangMengedit => widget.alamat != null;

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic>? alamat = widget.alamat;
    if (alamat == null) return;

    _labelAlamat = alamat['label_alamat']?.toString() ?? 'Rumah';
    _namaController.text = alamat['nama_penerima']?.toString() ?? '';
    _nomorHpController.text =
        _formatNomorUntukKolom(alamat['nomor_hp']?.toString() ?? '');
    _namaTempatController.text = alamat['nama_tempat']?.toString() ?? '';
    _detailController.text = alamat['detail_alamat']?.toString() ?? '';
    _alamatTeks = alamat['alamat_teks']?.toString() ?? '';
    _latitude = (alamat['latitude'] as num?)?.toDouble();
    _longitude = (alamat['longitude'] as num?)?.toDouble();
    _isDefault = alamat['is_default'] == true;
  }

  String _formatNomorUntukKolom(String value) {
    String nomor = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (nomor.startsWith('62')) nomor = nomor.substring(2);
    if (nomor.startsWith('0')) nomor = nomor.substring(1);
    return nomor;
  }

  String _formatNomorUntukDatabase(String value) {
    String nomor = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (nomor.startsWith('62')) nomor = nomor.substring(2);
    while (nomor.startsWith('0')) {
      nomor = nomor.substring(1);
    }
    return nomor.isEmpty ? '' : '0$nomor';
  }

  Future<void> _pilihLokasi() async {
    final Map<String, dynamic>? hasil =
        await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AmbilLokasiPage(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    setState(() {
      _latitude = (hasil['latitude'] as num).toDouble();
      _longitude = (hasil['longitude'] as num).toDouble();
      _alamatTeks = hasil['alamat_teks']?.toString() ?? '';
    });
  }

  Future<void> _simpanAlamat() async {
    final User? user = _supabase.auth.currentUser;
    final String nama = _namaController.text.trim();
    final String nomorInput = _nomorHpController.text.trim();
    final String detail = _detailController.text.trim();

    if (user == null) {
      _pesan('Sesi login tidak ditemukan.');
      return;
    }
    if (nama.isEmpty) {
      _pesan('Nama penerima wajib diisi.');
      return;
    }
    if (nomorInput.length < 9 || nomorInput.length > 13) {
      _pesan('Nomor telepon tidak valid.');
      return;
    }
    if (_latitude == null || _longitude == null || _alamatTeks.isEmpty) {
      _pesan('Pilih titik lokasi pengantaran terlebih dahulu.');
      return;
    }
    if (detail.isEmpty) {
      _pesan('Detail alamat atau patokan wajib diisi.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final List<dynamic> alamatYangAda = await _supabase
          .from('saved_addresses')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      final bool jadikanDefault = _isDefault || alamatYangAda.isEmpty;

      if (jadikanDefault) {
        await _supabase
            .from('saved_addresses')
            .update({'is_default': false}).eq('user_id', user.id);
      }

      final Map<String, dynamic> data = {
        'user_id': user.id,
        'label_alamat': _labelAlamat,
        'nama_penerima': nama,
        'nomor_hp': _formatNomorUntukDatabase(nomorInput),
        'nama_tempat': _namaTempatController.text.trim(),
        'alamat_teks': _alamatTeks,
        'detail_alamat': detail,
        'latitude': _latitude,
        'longitude': _longitude,
        'is_default': jadikanDefault,
      };

      if (_sedangMengedit) {
        await _supabase
            .from('saved_addresses')
            .update(data)
            .eq('id', widget.alamat!['id'])
            .eq('user_id', user.id);
      } else {
        await _supabase.from('saved_addresses').insert(data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Gagal menyimpan alamat: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      _pesan('Gagal menyimpan alamat: $e');
    }
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _namaTempatController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _sedangMengedit ? 'Edit Alamat' : 'Tambah Alamat',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMap(),
              const SizedBox(height: 24),
              _judul('LABEL ALAMAT'),
              Wrap(
                spacing: 10,
                children: ['Rumah', 'Kantor', 'Lainnya'].map((label) {
                  return ChoiceChip(
                    label: Text(label),
                    selected: _labelAlamat == label,
                    selectedColor: const Color(0xFFFADDE1),
                    labelStyle: TextStyle(
                      color: _labelAlamat == label ? _merah : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _labelAlamat = label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _judul('DETAIL PENERIMA'),
              _field(
                label: 'Nama Penerima',
                controller: _namaController,
                hint: 'Contoh: Budi Santoso',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              _field(
                label: 'Nomor Telepon',
                controller: _nomorHpController,
                hint: '81234567890',
                prefixText: '+62 ',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
              const SizedBox(height: 26),
              const Divider(),
              const SizedBox(height: 20),
              _judul('ALAMAT LENGKAP'),
              _field(
                label: 'Nama Gedung / Perumahan (opsional)',
                controller: _namaTempatController,
                hint: 'Contoh: Perumahan Padasari Indah',
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 16),
              _field(
                label: 'Detail Alamat / Patokan',
                controller: _detailController,
                hint: 'Contoh: Rumah coklat, pagar putih, dekat masjid',
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _merah,
                title: Text(
                  'Jadikan alamat utama',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Alamat utama dapat dipilih lebih cepat saat checkout.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanAlamat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED1C24),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan Alamat',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    final bool sudahMemilih = _latitude != null && _longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 230,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: sudahMemilih
              ? FlutterMap(
                  key: ValueKey('$_latitude,$_longitude'),
                  options: MapOptions(
                    initialCenter: lt.LatLng(_latitude!, _longitude!),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.laparmanten.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: lt.LatLng(_latitude!, _longitude!),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: _merah,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pilihLokasi,
          icon: const Icon(Icons.near_me, color: _merah),
          label: Text(
            sudahMemilih ? 'Ubah Lokasi di Maps' : 'Pilih Lokasi di Maps',
            style: GoogleFonts.poppins(
              color: _merah,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_alamatTeks.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _alamatTeks,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }

  Widget _judul(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    String? prefixText,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF664B4B))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _merah, width: 1.4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
          ),
        ),
      ],
    );
  }
}
