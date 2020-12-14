import 'dart:convert';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_instance.dart';

class CaseAdd {
  EpsState epsState;

  CaseAdd(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, CaseInstance>> addCase(
    String serviceUrl,
    bool useHttps,
    CaseInstance caseInstance,
  ) async {
    Uri uri;

    var path = '/case_definitions/' +
        caseInstance.caseDefinitionId.toString() +
        '/cases';

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
      "name": caseInstance.name,
      "description": caseInstance.description,
      "notes": [],
    };

    // get location
    var location = await epsState.geolocationHelper.getLocation();
    if (location != null) {
      body['latitude'] = location.latitude;
      body['longitude'] = location.longitude;
      body['position_accuracy'] = location.accuracy;
      body['altitude'] = location.altitude;
      body['altitude_accuracy'] = 0.0;
      body['heading'] = location.heading;
      body['speed'] = location.speed;
    }

    if (caseInstance.customFieldData != null ||
        caseInstance.customFieldData != '') {
      var data = json.decode(caseInstance.customFieldData)['data'];
      var adjusted = [];
      for (var item in data) {
        adjusted.add({
          "case_definition_custom_field_id":
              item['case_definition_custom_field_id'],
          "custom_section_id": item['custom_section_id'],
          "field_type": item['field_type'],
          "help_text": item['help_text'],
          "id": item['id'],
          "model_type": "Case",
          "name": item['name'],
          "selections": item['selections'],
          "sort_order": item['sort_order'],
          "validation_rules": item['validation_rules'],
          "value": item['value'],
          "created_at": item['created_at'],
          "created_by_id": epsState.user.id,
          "updated_at": item['updated_at'],
          "updated_by_id": epsState.user.id,
        });
      }
      body['custom_fields'] = adjusted;
    }

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // get properties back

      // id
      if (responseData.containsKey('id')) {
        caseInstance.id = responseData['id'];
      }

      // key
      if (responseData.containsKey('key')) {
        caseInstance.key = responseData['key'];
      }

      // created_at
      if (responseData.containsKey('created_at')) {
        caseInstance.createdAt = DateTime.parse(responseData['created_at']);
      }

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
