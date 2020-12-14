import 'dart:convert';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_instance.dart';

class CaseEditCustomField {
  EpsState epsState;

  CaseEditCustomField(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, CaseInstance>> editCaseCustomField(
    String serviceUrl,
    bool useHttps,
    CaseInstance caseInstance,
    String customFieldId,
    dynamic customFieldValue,
  ) async {
    Uri uri;

    var path = '/cases/' +
        caseInstance.id.toString() +
        '/custom_fields/' +
        customFieldId;

    if (useHttps) {
      uri = Uri.https(serviceUrl, path);
    } else {
      uri = Uri.http(serviceUrl, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "value": customFieldValue,
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // get properties back

      // updated_at
      if (responseData.containsKey('updated_at')) {
        caseInstance.updatedAt = DateTime.parse(responseData['updated_at']);
      }

      return Tuple2<bool, CaseInstance>(true, caseInstance);
    }

    // failure
    return Tuple2<bool, CaseInstance>(false, null);
  }
}
