import 'dart:convert';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_instance.dart';

class CaseEdit {
  EpsState epsState;

  CaseEdit(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, CaseInstance>> editCase(
    String serviceUrl,
    bool useHttps,
    CaseInstance caseInstance,
  ) async {
    Uri uri;

    var path = '/cases/' + caseInstance.id.toString();

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
      "status_id": caseInstance.caseStatusId,
    };

    if (caseInstance.caseStatusId == -1) {
      body.remove('status_id');
    }

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
