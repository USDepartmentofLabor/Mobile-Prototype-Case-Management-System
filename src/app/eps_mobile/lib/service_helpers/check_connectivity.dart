import 'package:connectivity/connectivity.dart';

class CheckConnectivity {
  static bool isOnline(ConnectivityResult connectivityResult) {
    return connectivityResult != ConnectivityResult.none;
  }
}
