import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class ActivityCustomFieldPut {
  static Future<bool> put(
    EpsState epsState,
    int activityId,
    String customFieldId,
    String value,
  ) async {
    Uri uri;

    var path = '/activities/' +
        activityId.toString() +
        '/custom_fields/' +
        customFieldId;

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {};

    body['value'] = value;

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    }

    print(uri.toString());
    print(response.statusCode.toString());
    print(response.body);

    // failure
    return false;
  }
}
