import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/models/service_info.dart';

class ConnectivityHelper {
  static bool getConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return true;
        break;
      case ConnectivityResult.mobile:
        return true;
        break;
      case ConnectivityResult.none:
        return false;
        break;
      default:
        return false;
        break;
    }
  }

  static Future<bool> isOnline() async {
    var result = await Connectivity().checkConnectivity();
    return getConnectionStatus(result);
  }

  static Future<bool> urlIsReachable(
    String url,
    bool useHttps,
  ) async {
    try {
      Uri uri;
      if (useHttps) {
        uri = Uri.https(url, '/');
      } else {
        uri = Uri.http(url, '/');
      }

      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> apiIsReachable(
    ServiceInfo serviceInfo,
  ) async {
    var result = await urlIsReachable(
      serviceInfo.url,
      serviceInfo.useHttps,
    );
    return result;
  }
}
