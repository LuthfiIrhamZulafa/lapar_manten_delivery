import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lt;
import 'package:geolocator/geolocator.dart';
import '../services/location_security_service.dart';

class MapSelectionWidget extends StatefulWidget {
  final Function(double lat, double lng, bool blocked, bool fakeGps, bool teleport, double accuracy) onLocationSelected;
  final LocationSecurityService locationSecurityService;

  const MapSelectionWidget({
    super.key,
    required this.onLocationSelected,
    required this.locationSecurityService,
  });

  @override
  State<MapSelectionWidget> createState() => _MapSelectionWidgetState();
}

class _MapSelectionWidgetState extends State<MapSelectionWidget> {
  final MapController _mapController = MapController();
  lt.LatLng _currentCenter = const lt.LatLng(-6.8383, 107.9221);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ambilLokasiSekarang();
  }

  Future<void> _ambilLokasiSekarang() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final result = await widget.locationSecurityService.checkLocation();
      final bool blocked = result['blocked'] as bool? ?? false;
      final bool fakeGps = result['fakeGps'] as bool? ?? false;
      final bool teleport = result['teleport'] as bool? ?? false;
      final double accuracy = result['accuracy'] as double? ?? position.accuracy;

     if (blocked) {
  if (!mounted) return;

  setState(() => _isLoading = false);
        widget.onLocationSelected(
          0.0,
          0.0,
          true,
          fakeGps,
          teleport,
          accuracy,
        );
        return;
      }

      if (!mounted) return;

setState(() {
  _currentCenter = lt.LatLng(position.latitude, position.longitude);
  _isLoading = false;
});

_mapController.move(_currentCenter, 16.0);

      setState(() {
        _currentCenter = lt.LatLng(position.latitude, position.longitude);
        _mapController.move(_currentCenter, 16.0);
        _isLoading = false;
      });

      widget.onLocationSelected(
        position.latitude,
        position.longitude,
        false,
        fakeGps,
        teleport,
        accuracy,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Gagal mengambil lokasi: $e');
    }
  }

  @override
void dispose() {
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.laparmanten.app',
                ),
              ],
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _ambilLokasiSekarang,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, color: Color(0xFFE52727)),
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
