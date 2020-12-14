import 'dart:convert';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class RequestPasswordReset {
  EpsState epsState;

  RequestPasswordReset(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<bool> sendRequestPasswordReset(
    String email,
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/auth/request-password-reset');
    } else {
      logInUri = Uri.http(serviceUrl, '/auth/request-password-reset');
    }

    var headers = {
      "Content-Type": "application/json",
    };

    var body = {
      "email": email,
    };

    final response =
        await http.post(logInUri, headers: headers, body: jsonEncode(body));
    return (response.statusCode == 200);
  }
}
