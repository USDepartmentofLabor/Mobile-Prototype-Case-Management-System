import 'dart:convert';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChangePassword {
  EpsState epsState;

  ChangePassword(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, EpsState>> changePassword(
    String serviceUrl,
    bool useHttps,
    String newPassword,
    String confirmNewPassword,
    int userId,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(
          serviceUrl, '/users/' + userId.toString() + '/change-password');
    } else {
      logInUri = Uri.http(
          serviceUrl, '/users/' + userId.toString() + '/change-password');
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "new_password": newPassword,
      "confirm_password": confirmNewPassword,
    };

    final logInResponse =
        await http.post(logInUri, headers: headers, body: jsonEncode(body));

    if (logInResponse.statusCode == 200) {
      return Tuple2<bool, EpsState>(true, this.epsState);
    }

    // failure
    return Tuple2<bool, EpsState>(false, null);
  }
}
