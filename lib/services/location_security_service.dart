import 'package:geolocator/geolocator.dart';
import 'package:root_checker_plus/root_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LocationSecurityService {
  Position? _lastPosition;

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

  Future<void> saveLocationHistory({

required double latitude,
required double longitude,
required double accuracy,
required int riskScore,

}) async {


final user =
Supabase.instance.client.auth.currentUser;


if(user == null){

print("USER BELUM LOGIN");

return;

}



await Supabase.instance.client
.from('location_history')
.insert({

'user_id': user.id,

'latitude': latitude,

'longitude': longitude,

'accuracy': accuracy,

'risk_score': riskScore,

});


print("LOCATION HISTORY BERHASIL");

}

 Future<bool> checkRoot() async {
  try {
    // Tambahkan 'as bool' setelah pemanggilan fungsi untuk meyakinkan Dart bahwa hasilnya adalah boolean
    bool isRooted = await RootCheckerPlus.isRootChecker as bool;
    return isRooted;
  } catch (e) {
    // Jika gagal atau tipe data tidak sesuai, kembalikan false agar aplikasi tidak macet
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


bool root = await checkRoot();
bool emulator = await checkEmulator();

if (fakeGps) {
  riskScore += 50;
}


if (badAccuracy) {
  riskScore += 20;
}


if (teleport) {
  riskScore += 40;
}


if (root) {
  riskScore += 40;
}

if (emulator) {

  riskScore += 30;

}

    await saveLocationHistory(

latitude: position.latitude,

longitude: position.longitude,

accuracy: position.accuracy,

riskScore: riskScore,

);
print("ROOT: $root");
print("RISK SCORE: $riskScore");
print("EMULATOR : $emulator");

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
      
    };
  }
}
