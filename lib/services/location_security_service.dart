import 'package:geolocator/geolocator.dart';

class LocationSecurityService {
  Position? _lastPosition;

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

      final DateTime currentTimestamp = position.timestamp ?? DateTime.now();
      final DateTime lastTimestamp = _lastPosition!.timestamp ?? currentTimestamp;
      final int seconds = currentTimestamp.difference(lastTimestamp).inSeconds;

      if (seconds > 0) {
        final double speed = distance / seconds;
        if (speed > 100) {
          teleport = true;
        }
      }
    }

    _lastPosition = position;

    int riskScore = 0;
    if (fakeGps) riskScore += 50;
    if (badAccuracy) riskScore += 20;
    if (teleport) riskScore += 40;

    return {
      'blocked': riskScore >= 70,
      'fakeGps': fakeGps,
      'teleport': teleport,
      'accuracy': position.accuracy,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'risk': riskScore,
      'timestamp': position.timestamp,
    };
  }
}
