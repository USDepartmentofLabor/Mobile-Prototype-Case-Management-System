import 'dart:convert';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/queries/survey_response_status_queries.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class GetSurveyResponse {
  EpsState epsState;

  GetSurveyResponse(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, SurveyResponse>> getSurveyResponse(
    Survey survey,
    int surveyResponseId,
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(
          serviceUrl,
          '/surveys/' +
              survey.id.toString() +
              '/responses/' +
              surveyResponseId.toString());
    } else {
      logInUri = Uri.http(
          serviceUrl,
          '/surveys/' +
              survey.id.toString() +
              '/responses/' +
              surveyResponseId.toString());
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var surveyResponse = new SurveyResponse();
      if (responseData.containsKey('id')) {
        surveyResponse.id = responseData['id'];
      }
      if (responseData.containsKey('survey_id')) {
        surveyResponse.surveyId = responseData['survey_id'];
      }
      if (responseData.containsKey('structure')) {
        surveyResponse.structure = responseData['structure'];
      }
      if (responseData.containsKey('status')) {
        var statusData = responseData['status'];
        if (statusData.containsKey('id')) {
          var surveyResponseStatusId = statusData['id'];
          if (await SurveyResponseStatusQueries.getSurveyResponseStatusIdExists(
            epsState.database.database,
            surveyResponseStatusId,
          )) {
            surveyResponse.statusId = surveyResponseStatusId;
          }
        }
      }
      if (responseData.containsKey('source_type')) {
        surveyResponse.sourceType = responseData['source_type'];
      }
      if (responseData.containsKey('case')) {
        surveyResponse.caseId = responseData['case'];
      }
      if (responseData.containsKey('created_at')) {
        surveyResponse.createdAt = DateTime.parse(responseData['created_at']);
      }
      if (responseData.containsKey('updated_at')) {
        surveyResponse.updatedAt = DateTime.parse(responseData['updated_at']);
      }
      if (responseData.containsKey('is_archived')) {
        surveyResponse.isArchived = responseData['is_archived'];
      }
      return Tuple2<bool, SurveyResponse>(true, surveyResponse);
    }

    // failure
    return Tuple2<bool, SurveyResponse>(false, null);
  }
}
