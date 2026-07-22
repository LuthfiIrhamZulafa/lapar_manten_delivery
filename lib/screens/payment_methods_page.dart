import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  static const Color _merah = Color(0xFFC60D2A);
  final SupabaseClient _supabase = Supabase.instance.client;

  String _metodeTerpilih = 'Transfer Bank';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ambilMetodeUtama();
  }

  Future<void> _ambilMetodeUtama() async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final Map<String, dynamic>? data = await _supabase
          .from('users')
          .select('metode_pembayaran_default')
          .eq('id', user.id)
          .maybeSingle();

      final String metode =
          data?['metode_pembayaran_default']?.toString() ?? 'Transfer Bank';

      if (!mounted) return;
      setState(() {
        _metodeTerpilih = metode == 'COD' ? 'COD' : 'Transfer Bank';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil metode pembayaran: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _pesan('Gagal mengambil metode pembayaran: $e', Colors.red);
    }
  }

  Future<void> _simpanMetodeUtama() async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      _pesan('Sesi login tidak ditemukan.', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabase
          .from('users')
          .update({'metode_pembayaran_default': _metodeTerpilih})
          .eq('id', user.id);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Gagal menyimpan metode pembayaran: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      _pesan('Gagal menyimpan metode pembayaran: $e', Colors.red);
    }
  }

  void _pesan(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _merah, size: 30),
        ),
        title: Text(
          'Metode Pembayaran',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.shopping_cart_outlined, color: _merah),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _merah))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pilih metode yang otomatis digunakan saat checkout.',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _paymentCard(
                            value: 'Transfer Bank',
                            title: 'Transfer Bank',
                            subtitle: 'Unggah bukti transfer setelah pembayaran',
                            icon: Icons.account_balance_outlined,
                          ),
                          const SizedBox(height: 16),
                          _paymentCard(
                            value: 'COD',
                            title: 'Bayar di Tempat (COD)',
                            subtitle: 'Bayar kepada driver ketika pesanan diterima',
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: 36),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.shield_outlined, color: _merah),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Aplikasi tidak menyimpan PIN, kata sandi, saldo, atau data kartu pelanggan.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontSize: 12,
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
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _simpanMetodeUtama,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFED1C24),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isSaving ? 'Menyimpan...' : 'Simpan Metode Utama',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _paymentCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = _metodeTerpilih == value;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      elevation: selected ? 4 : 1,
      shadowColor: selected ? _merah.withOpacity(0.22) : Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => setState(() => _metodeTerpilih = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? _merah : Colors.transparent,
              width: 1.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFDE8E8)
                      : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _merah, size: 31),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              selected
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF9EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'UTAMA',
                        style: TextStyle(
                          color: Color(0xFF159447),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
