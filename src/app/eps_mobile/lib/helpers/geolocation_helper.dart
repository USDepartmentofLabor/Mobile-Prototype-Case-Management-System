import 'package:geolocator/geolocator.dart';

class GeolocationHelper {
  Geolocator _geolocator;

  GeolocationHelper() {
    _geolocator = Geolocator();
  }

  Future<bool> getHasLocationPermissions() async {
    var status = await _geolocator.checkGeolocationPermissionStatus();
    return status == GeolocationStatus.granted;
  }

  Future<Position> getLocation() async {
    if (await getHasLocationPermissions()) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;
    }
    return null;
  }
}
