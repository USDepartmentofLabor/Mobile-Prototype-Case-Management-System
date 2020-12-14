import 'dart:convert';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class CaseDelete {
  static Future<Tuple2<bool, String>> deleteCase(
    EpsState epsState,
    int caseInstanceId,
  ) async {
    Uri uri;

    var path = '/cases/' + caseInstanceId.toString();

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken,
      "Accept-Language": epsState.localization.code,
    };

    final response = await http.delete(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var message = '';
      if (responseData.containsKey('message')) {
        message = responseData['message'];
      }
      return Tuple2<bool, String>(true, message);
    }

    // failure
    return Tuple2<bool, String>(
        false, 'error - ' + response.statusCode.toString());
  }
}
