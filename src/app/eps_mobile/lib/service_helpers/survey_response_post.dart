import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class SurveyResponsePost {
  EpsState epsState;

  SurveyResponsePost(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, SurveyResponse>> postResponse(
    String serviceUrl,
    bool useHttps,
    Survey survey,
    SurveyResponse surveyResponse,
    CaseInstance caseInstance,
  ) async {
    Uri uri;

    if (useHttps) {
      uri = Uri.https(
          serviceUrl, '/surveys/' + survey.id.toString() + '/responses');
    } else {
      uri = Uri.http(
          serviceUrl, '/surveys/' + survey.id.toString() + '/responses');
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "survey_id": survey.id,
      "structure": surveyResponse.structure,
      "status_id": 1,
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

    if (caseInstance != null) {
      body["source_type"] = "Case";
      body["case_id"] = caseInstance.id;
    }

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData.containsKey('id')) {
        surveyResponse.id = responseData['id'];
      }
      // get properties back

      // id
      if (responseData.containsKey('id')) {
        surveyResponse.id = responseData['id'];
      }

      // created_at
      if (responseData.containsKey('created_at')) {
        surveyResponse.createdAt = DateTime.parse(responseData['created_at']);
      }

      // updated_at
      if (responseData.containsKey('updated_at')) {
        surveyResponse.updatedAt = DateTime.parse(responseData['updated_at']);
      }

      return Tuple2<bool, SurveyResponse>(true, surveyResponse);
    }

    // failure
    return Tuple2<bool, SurveyResponse>(false, null);
  }
}
