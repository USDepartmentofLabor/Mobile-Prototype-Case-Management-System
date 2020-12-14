import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class SurveyResponseArchive {
  EpsState epsState;

  SurveyResponseArchive(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, SurveyResponse>> archiveResponse(
    String serviceUrl,
    bool useHttps,
    Survey survey,
    SurveyResponse surveyResponse,
    bool isArchived,
  ) async {
    Uri uri;

    if (useHttps) {
      uri = Uri.https(
          serviceUrl,
          '/surveys/' +
              survey.id.toString() +
              '/responses/' +
              surveyResponse.id.toString());
    } else {
      uri = Uri.http(
          serviceUrl,
          '/surveys/' +
              survey.id.toString() +
              '/responses/' +
              surveyResponse.id.toString());
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "id": surveyResponse.id,
      "survey": survey.id,
      "structure": surveyResponse.structure,
      "is_archived": isArchived ? true : false,
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

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
