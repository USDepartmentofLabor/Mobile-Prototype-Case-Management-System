import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class Logout {
  EpsState epsState;

  Logout(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, EpsState>> signOut(
    String serviceUrl,
    bool useHttps,
  ) async {
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/auth/logout');
    } else {
      logInUri = Uri.http(serviceUrl, '/auth/logout');
    }

    final logInResponse = await http.post(logInUri, headers: headers);

    if (logInResponse.statusCode == 200) {
      // clear out jwt
      this.epsState.user.jwtToken = '';
      return Tuple2<bool, EpsState>(true, this.epsState);
    }

    // failure
    return Tuple2<bool, EpsState>(false, null);
  }
}
