import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserLocationService {
  Future<({double? latitude, double? longitude})> getCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (latitude: null, longitude: null);
      }
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return (latitude: null, longitude: null);
      }
      final pos = await Geolocator.getCurrentPosition();
      return (latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return (latitude: null, longitude: null);
    }
  }
}
