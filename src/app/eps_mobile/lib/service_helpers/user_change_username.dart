import 'dart:convert';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class UserChangeUsername {
  EpsState epsState;

  UserChangeUsername(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, EpsState>> changeUsername(
    String serviceUrl,
    bool useHttps,
    String newUsername,
    int userId,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/users/' + userId.toString());
    } else {
      logInUri = Uri.http(serviceUrl, '/users/' + userId.toString());
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "id": userId,
      "username": newUsername,
    };

    final logInResponse =
        await http.put(logInUri, headers: headers, body: jsonEncode(body));

    if (logInResponse.statusCode == 200) {
      this.epsState.user.username = newUsername;
      return Tuple2<bool, EpsState>(true, this.epsState);
    }

    // failure
    return Tuple2<bool, EpsState>(false, null);
  }
}
