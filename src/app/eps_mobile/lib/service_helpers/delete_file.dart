import 'dart:async';
import 'package:eps_mobile/models/case_file.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class DeleteFile {
  static Future<bool> deleteFileAsync(
    EpsState epsState,
    CaseFile caseFile,
  ) async {
    Uri uri;

    var path = '/cases/files/' + caseFile.id.toString();

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.delete(uri, headers: headers);

    return response.statusCode == 200;
  }
}
