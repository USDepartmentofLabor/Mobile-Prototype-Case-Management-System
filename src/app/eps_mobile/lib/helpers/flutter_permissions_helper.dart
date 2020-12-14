/*
Note that PermissionsHelper is for mEPS specific application permissions
This (FlutterPermissionsHelper) is for regular platform permissions
i.e. camera, location, etc.
*/

import 'package:location_permissions/location_permissions.dart';

class FlutterPermissionsHelper {
  static Future<void> requestLocationPermissions() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    LocationPermissions().openAppSettings();
    print(permission.toString());
  }
}
