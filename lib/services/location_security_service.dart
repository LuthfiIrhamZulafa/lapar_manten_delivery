import 'package:geolocator/geolocator.dart';
import 'package:root_checker_plus/root_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSecurityService {
  Position? _lastPosition;
  DateTime? _lastHistoryAttempt;
  bool _isSavingHistory = false;

  bool? _cachedRoot;
  bool? _cachedEmulator;
  bool? _cachedVpn;
  DateTime? _lastVpnCheck;

  static const Duration _historyInterval =
      Duration(seconds: 30);

  static const Duration _vpnCheckInterval =
      Duration(minutes: 1);

  Future<bool> checkEmulator() async {
    

  try {

    final DeviceInfoPlugin deviceInfo =
        DeviceInfoPlugin();


    AndroidDeviceInfo android =
        await deviceInfo.androidInfo;


    return !android.isPhysicalDevice;


  } catch(e) {

    return false;

  }

}

Future<bool> checkVpn() async {

  try {

    final response = await http.get(
      Uri.parse("https://ipapi.co/json/")
    ).timeout(
      const Duration(seconds: 4),
    );

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      String org =
          (data['org'] ?? "")
              .toString()
              .toLowerCase();

      String asn =
          (data['asn'] ?? "")
              .toString()
              .toLowerCase();

      if(
        org.contains("vpn") ||
        org.contains("proxy") ||
        asn.contains("vpn")
      ){

        return true;

      }

    }

    return false;

  }catch(e){

    print("VPN CHECK ERROR : $e");

    return false;

  }

}

Future<bool> _checkVpnCached() async {
  final DateTime sekarang = DateTime.now();

  if (_cachedVpn != null &&
      _lastVpnCheck != null &&
      sekarang.difference(_lastVpnCheck!) <
          _vpnCheckInterval) {
    return _cachedVpn!;
  }

  final bool hasil = await checkVpn();

  _cachedVpn = hasil;
  _lastVpnCheck = sekarang;

  return hasil;
}

Future<void> saveLocationHistory({
  required double latitude,
  required double longitude,
  required double accuracy,
  required int riskScore,
  required bool fakeGps,
  required bool teleport,
  required bool emulator,
  required bool root,
  required bool vpn,
  required String status,
}) async {
  final user =
      Supabase.instance.client.auth.currentUser;

  if (user == null) {
    print("USER BELUM LOGIN");
    return;
  }

  final DateTime sekarang = DateTime.now();

  // Data ALLOWED cukup disimpan setiap 30 detik
  if (status == "ALLOWED" &&
      _lastHistoryAttempt != null &&
      sekarang.difference(_lastHistoryAttempt!) <
          _historyInterval) {
    return;
  }

  // Mencegah beberapa insert berjalan bersamaan
  if (_isSavingHistory) {
    return;
  }

  if (status == "ALLOWED") {
    _lastHistoryAttempt = sekarang;
  }

  _isSavingHistory = true;

  try {
    await Supabase.instance.client
        .from('location_history')
        .insert({
          'user_id': user.id,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'risk_score': riskScore,
          'fake_gps': fakeGps,
          'teleport': teleport,
          'emulator': emulator,
          'root': root,
          'vpn': vpn,
          'status': status,
        })
        .timeout(const Duration(seconds: 8));

    print("LOCATION HISTORY BERHASIL");
  } catch (e) {
    // Jangan menghentikan pemeriksaan keamanan
    // hanya karena pencatatan Supabase gagal.
    print("LOCATION HISTORY GAGAL: $e");
  } finally {
    _isSavingHistory = false;
  }
}

Future<bool> checkRoot() async {
  try {
    return (await RootCheckerPlus.isRootChecker()) ??
        false;
  } catch (e) {
    print("ROOT CHECK ERROR: $e");
    return false;
  }
}

  Future<Map<String, dynamic>> checkLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'blocked': true};
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {'blocked': true};
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {'blocked': true};
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    return evaluateLocation(position);
  }

 Future<Map<String, dynamic>> checkLocationSecurity(Position position) async {
  return await evaluateLocation(position);
}

  Future<Map<String, dynamic>> evaluateLocation(Position position) async {
    final bool fakeGps = position.isMocked;
    final bool badAccuracy = position.accuracy <= 0 || position.accuracy > 30;
    bool teleport = false;

    if (_lastPosition != null) {
      final double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      final DateTime currentTimestamp = position.timestamp;

      final DateTime lastTimestamp = _lastPosition!.timestamp;

      final int seconds = currentTimestamp.difference(lastTimestamp).inSeconds;

      if (seconds > 0) {
        final double speed = distance / seconds;

        if (speed > 100) {

  teleport = true;

  print("TELEPORT TERDETEKSI");
  print("Kecepatan: $speed m/detik");

}
      }
    }

    _lastPosition = position;

    int riskScore = 0;


_cachedRoot ??= await checkRoot();
_cachedEmulator ??= await checkEmulator();

final bool root = _cachedRoot!;
final bool emulator = _cachedEmulator!;
final bool vpn = await _checkVpnCached();

// BLOCK LANGSUNG JIKA FAKE GPS
if (fakeGps) {

  await saveLocationHistory(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    riskScore: riskScore,
    fakeGps: fakeGps,
    teleport: teleport,
    emulator: emulator,
    root: root,
    vpn: vpn,
    status: "BLOCKED",
  );

  return {
    'blocked': true,
    'reason': 'Fake GPS terdeteksi',
    'fakeGps': true,
  };
}

// BLOCK LANGSUNG JIKA ROOT
if (root) {

  await saveLocationHistory(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    riskScore: riskScore,
    fakeGps: fakeGps,
    teleport: teleport,
    emulator: emulator,
    root: root,
    vpn: vpn,
    status: "BLOCKED",
  );

  return {
    'blocked': true,
    'reason': 'Perangkat Root terdeteksi',
    'root': true,
  };
}

// BLOCK LANGSUNG JIKA EMULATOR
if (emulator) {

  await saveLocationHistory(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    riskScore: riskScore,
    fakeGps: fakeGps,
    teleport: teleport,
    emulator: emulator,
    root: root,
    vpn: vpn,
    status: "BLOCKED",
  );

  return {
    'blocked': true,
    'reason': 'Emulator terdeteksi',
    'emulator': true,
  };
}



if (badAccuracy) {
  riskScore += 20;
}


if (teleport) {
  riskScore += 40;
}


if (vpn) {
  riskScore += 10;
  print("VPN ATAU PROXY TERDETEKSI");
}

   await saveLocationHistory(
  latitude: position.latitude,
  longitude: position.longitude,
  accuracy: position.accuracy,
  riskScore: riskScore,
  fakeGps: fakeGps,
  teleport: teleport,
  emulator: emulator,
  root: root,
  vpn: vpn,
  status: "ALLOWED",
);
print("ROOT: $root");
print("FAKE GPS : $fakeGps");
print("VPN : $vpn");
print("TELEPORT : $teleport");
print("EMULATOR : $emulator");
print("AKURASI : ${position.accuracy}");
print("RISK SCORE : $riskScore");

    return {
      'blocked': riskScore >= 70,
      'fakeGps': fakeGps,
      'teleport': teleport,
      'root': root,
      'emulator': emulator,
      'accuracy': position.accuracy,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'risk': riskScore,
      'timestamp': position.timestamp,
      'vpn': vpn,

      
    };
  }
}
