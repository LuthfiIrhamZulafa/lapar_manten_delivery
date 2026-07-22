import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_address_page.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  static const Color _merah = Color(0xFFC60D2A);
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final User? user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final List<dynamic> response = await _supabase
          .from('saved_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _addresses = response
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil alamat: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil alamat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bukaForm([Map<String, dynamic>? alamat]) async {
    final bool? berubah = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressPage(alamat: alamat),
      ),
    );

    if (berubah == true) {
      setState(() => _isLoading = true);
      await _loadAddresses();
    }
  }

  Future<void> _jadikanUtama(Map<String, dynamic> alamat) async {
    final User? user = _supabase.auth.currentUser;
    if (user == null || alamat['is_default'] == true) return;

    try {
      await _supabase
          .from('saved_addresses')
          .update({'is_default': false}).eq('user_id', user.id);

      await _supabase
          .from('saved_addresses')
          .update({'is_default': true})
          .eq('id', alamat['id'])
          .eq('user_id', user.id);

      await _loadAddresses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah alamat utama: $e')),
      );
    }
  }

  Future<void> _hapusAlamat(Map<String, dynamic> alamat) async {
    final bool? setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: _merah),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (setuju != true) return;

    try {
      await _supabase
          .from('saved_addresses')
          .delete()
          .eq('id', alamat['id']);
      await _loadAddresses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus alamat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          'Alamat Tersimpan',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _merah))
          : _addresses.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                    itemCount: _addresses.length,
                    itemBuilder: (_, index) => _addressCard(_addresses[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        backgroundColor: _merah,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Tambah Alamat'),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined, size: 90, color: Colors.grey),
            const SizedBox(height: 18),
            Text(
              'Belum ada alamat tersimpan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan alamat agar data penerima dapat digunakan kembali.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressCard(Map<String, dynamic> alamat) {
    final bool utama = alamat['is_default'] == true;
    final String tempat = alamat['nama_tempat']?.toString() ?? '';
    final String detail = alamat['detail_alamat']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _bukaForm(alamat),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: _merah),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alamat['label_alamat']?.toString() ?? 'Alamat',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (utama)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Utama',
                        style: TextStyle(
                          color: _merah,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alamat['nama_penerima']?.toString() ?? '-',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(
                alamat['nomor_hp']?.toString() ?? '-',
                style: GoogleFonts.poppins(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              if (tempat.isNotEmpty)
                Text(tempat, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              Text(
                alamat['alamat_teks']?.toString() ?? '-',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  'Patokan: $detail',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
              const Divider(height: 26),
              Row(
                children: [
                  if (!utama)
                    TextButton(
                      onPressed: () => _jadikanUtama(alamat),
                      child: const Text('Jadikan Utama'),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => _bukaForm(alamat),
                    icon: const Icon(Icons.edit_outlined, color: _merah),
                  ),
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: () => _hapusAlamat(alamat),
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
