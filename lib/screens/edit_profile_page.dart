import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _nomorHpController =
      TextEditingController();

  Map<String, dynamic>? _profileData;

  bool _isLoading = true;
  bool _isSaving = false;

  String _memberSejak = "-";
  String? _avatarUrl;
  final ImagePicker _imagePicker =
    ImagePicker();

Uint8List? _fotoBaruBytes;

String _fotoExtension = 'jpg';
String _fotoContentType = 'image/jpeg';

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
  }

  Future<void> _ambilDataProfil() async {
    final User? user =
        _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final Map<String, dynamic>? data =
          await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      final Map<String, dynamic> metadata =
          user.userMetadata ??
              <String, dynamic>{};

      final String nama =
          data?['nama_lengkap']?.toString() ??
              metadata['full_name']?.toString() ??
              metadata['name']?.toString() ??
              user.email?.split('@').first ??
              '';

      final String email =
          data?['email']?.toString() ??
              user.email ??
              '';

      final String nomorHp =
          data?['nomor_hp']?.toString() ??
              user.phone ??
              '';

      _namaController.text = nama;
      _emailController.text = email;
      _nomorHpController.text =
          _formatNomorUntukKolom(nomorHp);

      final dynamic createdAt =
          data?['created_at'] ??
              user.createdAt;

      if (!mounted) return;

      setState(() {
        _profileData = data;

        _avatarUrl =
            data?['foto_profil']?.toString() ??
                metadata['avatar_url']?.toString() ??
                metadata['picture']?.toString();

        _memberSejak =
            _formatMemberSejak(createdAt);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Gagal mengambil profil: $e",
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengambil profil: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatNomorUntukKolom(
    String nomorHp,
  ) {
    String nomor = nomorHp.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (nomor.startsWith('62')) {
      nomor = nomor.substring(2);
    }

    if (nomor.startsWith('0')) {
      nomor = nomor.substring(1);
    }

    return nomor;
  }

  String _formatNomorUntukDatabase(
    String nomorHp,
  ) {
    String nomor = nomorHp.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (nomor.startsWith('62')) {
      nomor = nomor.substring(2);
    }

    while (nomor.startsWith('0')) {
      nomor = nomor.substring(1);
    }

    if (nomor.isEmpty) {
      return '';
    }

    return '0$nomor';
  }

  String _formatMemberSejak(
    dynamic createdAt,
  ) {
    if (createdAt == null) {
      return "-";
    }

    final DateTime? tanggal =
        DateTime.tryParse(
      createdAt.toString(),
    )?.toLocal();

    if (tanggal == null) {
      return "-";
    }

    const List<String> bulan = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];

    return "${bulan[tanggal.month - 1]} "
        "${tanggal.year}";
  }

  Future<void> _simpanPerubahan() async {
    final String nama =
        _namaController.text.trim();

    final String nomorInput =
        _nomorHpController.text.trim();

    if (nama.isEmpty) {
      _tampilkanPesan(
        "Nama lengkap tidak boleh kosong.",
        Colors.red,
      );
      return;
    }

    if (nomorInput.isEmpty) {
      _tampilkanPesan(
        "Nomor telepon tidak boleh kosong.",
        Colors.red,
      );
      return;
    }

    if (nomorInput.length < 9 ||
        nomorInput.length > 13) {
      _tampilkanPesan(
        "Nomor telepon tidak valid.",
        Colors.red,
      );
      return;
    }

    final User? user =
        _supabase.auth.currentUser;

    if (user == null) {
      _tampilkanPesan(
        "Sesi login tidak ditemukan.",
        Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String nomorDatabase =
    _formatNomorUntukDatabase(
  nomorInput,
);

String? fotoProfilUrl = _avatarUrl;

// Upload hanya jika pelanggan memilih foto baru.
if (_fotoBaruBytes != null) {
  final String pathFoto =
      '${user.id}/avatar.$_fotoExtension';

  await _supabase.storage
      .from('profile-photos')
      .uploadBinary(
        pathFoto,
        _fotoBaruBytes!,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _fotoContentType,
        ),
      );

  final String publicUrl =
      _supabase.storage
          .from('profile-photos')
          .getPublicUrl(pathFoto);

  // Parameter waktu mencegah foto lama tersimpan di cache.
  fotoProfilUrl =
      '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
}

await _supabase
    .from('users')
    .upsert(
      {
        'id': user.id,
        'nama_lengkap': nama,
        'nomor_hp': nomorDatabase,
        'email':
            user.email ??
                _emailController.text.trim(),
        'alamat_default':
            _profileData?[
                    'alamat_default'] ??
                '',
        'foto_profil': fotoProfilUrl,
      },
      onConflict: 'id',
    );

      // Menyamakan nama di Supabase Auth.
      try {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': nama,
              'name': nama,
            },
          ),
        );
      } catch (e) {
        debugPrint(
          "Gagal memperbarui metadata: $e",
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint(
        "Gagal menyimpan profil: $e",
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _tampilkanPesan(
        "Gagal menyimpan profil: $e",
        Colors.red,
      );
    }
  }

  void _tampilkanPesan(
    String pesan,
    Color warna,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
      ),
    );
  }

  Future<void> _pilihFotoProfil() async {
  final ImageSource? sumber =
      await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFC60D2A),
                ),
                title: const Text(
                  "Ambil dari Kamera",
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFC60D2A),
                ),
                title: const Text(
                  "Pilih dari Galeri",
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
                title: const Text("Batal"),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (sumber == null) {
    return;
  }

  try {
    final XFile? file =
        await _imagePicker.pickImage(
      source: sumber,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (file == null) {
      return;
    }

    final Uint8List bytes =
        await file.readAsBytes();

    // Maksimal 5 MB.
    if (bytes.lengthInBytes >
        5 * 1024 * 1024) {
      if (!mounted) return;

      _tampilkanPesan(
        "Ukuran foto maksimal 5 MB.",
        Colors.red,
      );
      return;
    }

    final String namaFile =
        file.name.toLowerCase();

    if (namaFile.endsWith('.png')) {
      _fotoExtension = 'png';
      _fotoContentType = 'image/png';
    } else if (
        namaFile.endsWith('.webp')) {
      _fotoExtension = 'webp';
      _fotoContentType = 'image/webp';
    } else {
      _fotoExtension = 'jpg';
      _fotoContentType = 'image/jpeg';
    }

    if (!mounted) return;

    setState(() {
      _fotoBaruBytes = bytes;
    });
  } catch (e) {
    debugPrint(
      "Gagal memilih foto: $e",
    );

    if (!mounted) return;

    _tampilkanPesan(
      "Gagal memilih foto: $e",
      Colors.red,
    );
  }
}

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color merah =
        Color(0xFFC60D2A);

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: merah,
            size: 30,
          ),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: const Color(0xFF202020),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: merah,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  24,
                  30,
                  24,
                  30,
                ),
                child: Column(
                  children: [
                    _buildFotoProfil(),

                    const SizedBox(height: 45),

                    _buildKolom(
                      label: "Nama Lengkap",
                      controller:
                          _namaController,
                      hintText:
                          "Masukkan nama lengkap",
                      keyboardType:
                          TextInputType.name,
                    ),

                    const SizedBox(height: 22),

                    _buildKolom(
                      label: "Email",
                      controller:
                          _emailController,
                      hintText:
                          "Alamat email",
                      keyboardType:
                          TextInputType.emailAddress,
                      readOnly: true,
                    ),

                    const SizedBox(height: 22),

                    _buildKolom(
                      label: "Nomor Telepon",
                      controller:
                          _nomorHpController,
                      hintText: "81234567890",
                      keyboardType:
                          TextInputType.phone,
                      prefixText: "+62 ",
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          13,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildInfoCard(
                            icon:
                                Icons.verified_outlined,
                            title: "Status",
                            value: "Terverifikasi",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              _buildInfoCard(
                            icon:
                                Icons.calendar_month,
                            title: "Member Sejak",
                            value:
                                _memberSejak,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSaving
                                ? null
                                : _simpanPerubahan,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFED1C24,
                          ),
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              Colors.grey[300],
                          elevation: 5,
                          shadowColor:
                              Colors.red
                                  .withOpacity(0.3),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .check_circle_outline,
                              ),
                        label: Text(
                          _isSaving
                              ? "Menyimpan..."
                              : "Simpan Perubahan",
                          style:
                              GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w600,
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

  Widget _buildFotoProfil() {
    final bool memilikiFotoLama =
    _avatarUrl != null &&
        _avatarUrl!.isNotEmpty;

final ImageProvider? fotoProvider;

if (_fotoBaruBytes != null) {
  fotoProvider =
      MemoryImage(_fotoBaruBytes!);
} else if (memilikiFotoLama) {
  fotoProvider =
      NetworkImage(_avatarUrl!);
} else {
  fotoProvider = null;
}

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 138,
              height: 138,
              padding:
                  const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color:
                      const Color(0xFFE5E5E5),
                  width: 5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor:
                    const Color(0xFFF5F5F5),
                backgroundImage: fotoProvider,
child: fotoProvider != null
    ? null
    : const Icon(
                        Icons.person,
                        size: 78,
                        color:
                            Color(0xFF292323),
                      ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 4,
              child: GestureDetector(
                onTap: _pilihFotoProfil,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xFFC60D2A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Ubah Foto Profil",
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildKolom({
    required String label,
    required TextEditingController
        controller,
    required String hintText,
    required TextInputType
        keyboardType,
    bool readOnly = false,
    String? prefixText,
    List<TextInputFormatter>?
        inputFormatters,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color:
                const Color(0xFF664B4B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters:
              inputFormatters,
          style: GoogleFonts.poppins(
            color:
                const Color(0xFF292929),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            filled: true,
            fillColor: readOnly
                ? const Color(0xFFF1F1F1)
                : const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  BorderSide.none,
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  BorderSide.none,
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFFC60D2A),
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 19,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 92,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F6F6),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAE7E7),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFFC60D2A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        Colors.black87,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                        Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}